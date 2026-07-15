// =========================================
// NovaMente Authentication
// Sprint 10
// =========================================

// ---------- REGISTRO ----------

async function register(fullName, email, password) {

    const { data, error } = await supabase.auth.signUp({

        email,

        password,

        options: {

            data: {

                full_name: fullName

            }

        }

    });

    if (error) {

        alert(error.message);

        return;

    }

    alert("Revisa tu correo para confirmar tu cuenta.");

    window.location.href = "login.html";

}



// ---------- LOGIN ----------

async function login(email, password) {

    const { error } = await supabase.auth.signInWithPassword({

        email,

        password

    });

    if (error) {

        alert(error.message);

        return;

    }

    window.location.href = "../dashboard/index.html";

}



// ---------- RECUPERAR CONTRASEÑA ----------

async function forgotPassword(email) {

    const { error } = await supabase.auth.resetPasswordForEmail(email, {

        redirectTo: window.location.origin +

        "/frontend/auth/update-password.html"

    });

    if (error) {

        alert(error.message);

        return;

    }

    alert("Te enviamos un correo para restablecer tu contraseña.");

}



// ---------- CERRAR SESIÓN ----------

async function logout() {

    await supabase.auth.signOut();

    window.location.href = "../auth/login.html";

}
