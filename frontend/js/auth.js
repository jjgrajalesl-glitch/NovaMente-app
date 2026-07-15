/* ==========================================
   NovaMente
   Authentication Module
   Sprint 10.2
========================================== */

async function register(userData) {

    const { data, error } = await supabase.auth.signUp({

        email: userData.email,

        password: userData.password,

        options: {

            data: {

                first_name: userData.firstName,

                last_name: userData.lastName

            }

        }

    });

    if (error) {

        alert(error.message);

        return null;

    }

    return data;

}



async function login(email, password) {

    const { data, error } = await supabase.auth.signInWithPassword({

        email,

        password

    });

    if (error) {

        alert(error.message);

        return null;

    }

    window.location.href = "../dashboard/index.html";

}



async function forgotPassword(email) {

    const { error } = await supabase.auth.resetPasswordForEmail(email);

    if (error) {

        alert(error.message);

        return;

    }

    alert("Te enviamos un correo para recuperar tu contraseña.");

}



async function logout() {

    await supabase.auth.signOut();

    window.location.href = "../auth/login.html";

}
