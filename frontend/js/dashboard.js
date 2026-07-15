document.addEventListener("DOMContentLoaded", async () => {

    const {

        data: { session }

    } = await supabase.auth.getSession();

    if (!session) {

        window.location.href = "../auth/login.html";

        return;

    }

    const user = session.user;

    const { data: profile } = await supabase

        .from("profiles")

        .select("*")

        .eq("id", user.id)

        .single();

    const { data: subscription } = await supabase

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

    await supabase.auth.signOut();

    window.location.href="../auth/login.html";

});
