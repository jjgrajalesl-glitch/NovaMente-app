// =====================================================================
// NOVAMENTE · JOHN MENTOR DIARIO (Vercel Function + Vercel Cron)
// Cada día: Gemini escribe la técnica (ES/PT/EN) → Gemini la convierte en voz
// → se arma un video vertical (imagen + voz + aviso de IA) → se envía a Telegram.
// No guarda archivos: todo vive en /tmp y se borra al terminar.
// Variables (Vercel → Settings → Environment Variables):
//   CRON_SECRET, GEMINI_API_KEY, GEMINI_TEXT_MODEL, GEMINI_TTS_MODEL, GEMINI_VOICE,
//   TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ES, TELEGRAM_CHAT_PT, TELEGRAM_CHAT_EN
// =====================================================================
const fs = require("fs");
const path = require("path");
const os = require("os");
const { execFile } = require("child_process");

const IMG = fs.readFileSync(path.join(__dirname, "_media", "john-mentor-video.jpg"));
const FONT = fs.readFileSync(path.join(__dirname, "_media", "DejaVuSans-Bold.ttf"));

const GEMINI = "https://generativelanguage.googleapis.com/v1beta/models/";
const IDIOMAS = ["es", "pt", "en"];
const ETIQUETA = { es: "Video generado con IA", pt: "Vídeo gerado com IA", en: "AI-generated video" };
const TITULO = { es: "John Mentor · Técnica del día", pt: "John Mentor · Técnica do dia", en: "John Mentor · Today's technique" };

const INSTRUCCIONES = `Eres John Mentor, mentor del Club NovaMente. Escribe la técnica del día para crear disciplina y cumplir objetivos.
Elige UNA técnica práctica y concreta (ejemplos: "si pasa X, entonces haré Y", regla de 2 minutos, encadenar hábitos, bloques de tiempo, compromiso previo, replantear un pensamiento que frena). Varía la técnica cada día.
Formato de cada texto: empieza con "Hola, soy John Mentor, un mentor creado con inteligencia artificial." (en su idioma), luego 60 a 80 palabras, tono cálido y directo, un paso para hacer hoy, y termina con una pregunta para comentar en el grupo.
Prohibido: diagnosticar, prometer mejorar la salud o la inteligencia, presentarte como terapeuta o profesional de salud, dar consejo médico.
Responde SOLO con este JSON: {"es":"...","pt":"...","en":"..."}`;

function ffmpegPath(){ return process.env.FFMPEG_PATH || require("ffmpeg-static"); }
function run(bin, args){
  return new Promise((ok, mal) => execFile(bin, args, { maxBuffer: 1 << 26 }, (err, so, se) => err ? mal(new Error(String(se).slice(-600))) : ok()));
}
async function gemini(model, body){
  const r = await fetch(GEMINI + encodeURIComponent(model) + ":generateContent", {
    method: "POST",
    headers: { "Content-Type": "application/json", "x-goog-api-key": process.env.GEMINI_API_KEY },
    body: JSON.stringify(body)
  });
  const j = await r.json().catch(() => ({}));
  if(!r.ok) throw new Error("Gemini " + r.status + ": " + JSON.stringify(j).slice(0, 400));
  return j;
}

async function escribirTextos(){
  const j = await gemini(process.env.GEMINI_TEXT_MODEL, {
    systemInstruction: { parts: [{ text: INSTRUCCIONES }] },
    contents: [{ role: "user", parts: [{ text: "Escribe la técnica de hoy. Fecha: " + new Date().toISOString().slice(0, 10) }] }],
    generationConfig: { responseMimeType: "application/json", temperature: 0.9 }
  });
  const txt = (j.candidates?.[0]?.content?.parts || []).map(p => p.text || "").join("");
  const t = JSON.parse(txt);
  for(const l of IDIOMAS) if(typeof t[l] !== "string" || t[l].length < 40) throw new Error("Texto incompleto en " + l);
  return t;
}

async function voz(texto){
  const j = await gemini(process.env.GEMINI_TTS_MODEL, {
    contents: [{ parts: [{ text: texto }] }],
    generationConfig: {
      responseModalities: ["AUDIO"],
      speechConfig: { voiceConfig: { prebuiltVoiceConfig: { voiceName: process.env.GEMINI_VOICE || "Kore" } } }
    }
  });
  const parte = (j.candidates?.[0]?.content?.parts || []).find(p => p.inlineData && p.inlineData.data);
  if(!parte) throw new Error("Gemini no devolvió audio");
  return Buffer.from(parte.inlineData.data, "base64");
}

async function armarVideo(dir, idioma, audio){
  const img = path.join(dir, "img.jpg"), font = path.join(dir, "font.ttf");
  if(!fs.existsSync(img)) fs.writeFileSync(img, IMG);
  if(!fs.existsSync(font)) fs.writeFileSync(font, FONT);
  const esWav = audio.slice(0, 4).toString("ascii") === "RIFF";        // los modelos nuevos entregan WAV; los anteriores, PCM 24 kHz
  const aud = path.join(dir, idioma + (esWav ? ".wav" : ".pcm"));
  fs.writeFileSync(aud, audio);
  const t1 = path.join(dir, idioma + "_t1.txt"), t2 = path.join(dir, idioma + "_t2.txt");
  fs.writeFileSync(t1, ETIQUETA[idioma]); fs.writeFileSync(t2, TITULO[idioma]);
  const out = path.join(dir, idioma + ".mp4");
  const f = font.replace(/\\/g, "/");
  const vf = [
    "scale=720:1280:force_original_aspect_ratio=increase", "crop=720:1280",
    `drawbox=x=0:y=0:w=iw:h=86:color=0x163B72@0.85:t=fill`,
    `drawtext=fontfile=${f}:textfile=${t1}:fontcolor=white:fontsize=30:x=(w-text_w)/2:y=28`,
    `drawbox=x=0:y=ih-110:w=iw:h=110:color=0x163B72@0.85:t=fill`,
    `drawtext=fontfile=${f}:textfile=${t2}:fontcolor=white:fontsize=34:x=(w-text_w)/2:y=h-72`
  ].join(",");
  const entradaAudio = esWav ? ["-i", aud] : ["-f", "s16le", "-ar", "24000", "-ac", "1", "-i", aud];
  await run(ffmpegPath(), ["-y", "-loop", "1", "-framerate", "24", "-i", img, ...entradaAudio,
    "-vf", vf, "-c:v", "libx264", "-preset", "veryfast", "-tune", "stillimage", "-pix_fmt", "yuv420p",
    "-c:a", "aac", "-b:a", "128k", "-shortest", "-movflags", "+faststart", out]);
  return out;
}

async function enviarTelegram(chat, video, texto){
  const fd = new FormData();
  fd.append("chat_id", chat);
  fd.append("caption", texto.length > 1000 ? texto.slice(0, 997) + "…" : texto);
  fd.append("supports_streaming", "true");
  fd.append("video", new Blob([fs.readFileSync(video)], { type: "video/mp4" }), "john-mentor.mp4");
  const r = await fetch("https://api.telegram.org/bot" + process.env.TELEGRAM_BOT_TOKEN + "/sendVideo", { method: "POST", body: fd });
  const j = await r.json().catch(() => ({}));
  if(!j.ok) throw new Error("Telegram: " + JSON.stringify(j).slice(0, 300));
}

module.exports = async function handler(req, res){
  if(!process.env.CRON_SECRET || req.headers.authorization !== "Bearer " + process.env.CRON_SECRET){
    return res.status(401).json({ ok: false, error: "No autorizado" });
  }
  const faltan = ["GEMINI_API_KEY","GEMINI_TEXT_MODEL","GEMINI_TTS_MODEL","TELEGRAM_BOT_TOKEN"].filter(k => !process.env[k]);
  if(faltan.length) return res.status(500).json({ ok: false, error: "Faltan variables: " + faltan.join(", ") });

  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "nm-"));
  const resultado = {};
  try{
    const textos = await escribirTextos();
    for(const l of IDIOMAS){
      const chat = process.env["TELEGRAM_CHAT_" + l.toUpperCase()];
      if(!chat){ resultado[l] = "sin canal configurado"; continue; }
      try{
        const audio = await voz(textos[l]);
        const video = await armarVideo(dir, l, audio);
        await enviarTelegram(chat, video, textos[l]);
        resultado[l] = "enviado";
      }catch(e){ resultado[l] = "error: " + e.message; }
    }
    const ok = Object.values(resultado).some(v => v === "enviado");
    return res.status(ok ? 200 : 500).json({ ok, resultado });
  }catch(e){
    return res.status(500).json({ ok: false, error: e.message, resultado });
  }finally{
    fs.rmSync(dir, { recursive: true, force: true });
  }
};
