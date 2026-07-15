document.addEventListener("DOMContentLoaded", async () => {

    const {

        data: { session }

    } = await novasupabase.auth.getSession();

    if (!session) {

        window.location.href = "../auth/login.html";

        return;

    }

    const user = session.user;

    const { data: profile } = await novasupabase

        .from("profiles")

        .select("*")

        .eq("id", user.id)

        .single();

    const { data: subscription } = await novasupabase

        .schema("identity")

        .from("subscriptions")

        .select("*")

        .eq("user_id", user.id)

        .single();

    document.getElementById("welcomeMessage").innerText =
        "Hola " + (profile.full_name || "Usuario");

    document.getElementById("subscriptionStatus").innerText =
        subscription.plan;

    document.getElementById("level").innerText =
        profile.level;

    document.getElementById("xp").innerText =
        profile.xp;

    document.getElementById("streak").innerText =
        profile.current_streak;

});

document

.getElementById("logoutButton")

.addEventListener("click", async () => {

    await novasupabase.auth.signOut();

    window.location.href="../auth/login.html";

});
