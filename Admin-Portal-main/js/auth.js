import { auth, db } from "./firebase-config.js";
import {
  GoogleAuthProvider,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut
} from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import {
  doc,
  getDoc,
  setDoc,
  serverTimestamp
} from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const ADMIN_ROLE = "admin";
const LOGOUT_MARKER = "qualimeat_logged_out";

async function getUserAccess(user) {
  if (!user) return null;

  const userRef = doc(db, "users", user.uid);
  const snapshot = await getDoc(userRef);
  return snapshot.exists() ? snapshot.data() : null;
}

async function isApprovedAdmin(user) {
  const profile = await getUserAccess(user);
  return profile?.role === ADMIN_ROLE && profile?.enabled === true;
}

async function denyAccess(message = "This account is not approved as an administrator.") {
  await signOut(auth);
  alert(message);
}

/* EMAIL/PASSWORD LOGIN */
window.login = async function (event) {
  event.preventDefault();

  const email = document.getElementById("email").value.trim();
  const password = document.getElementById("password").value;

  try {
    const credential = await signInWithEmailAndPassword(auth, email, password);

    if (!(await isApprovedAdmin(credential.user))) {
      await denyAccess("Access denied. Ask the system owner to approve this account and set role = admin.");
      return;
    }

    sessionStorage.removeItem(LOGOUT_MARKER);
    window.location.replace("dashboard.html");
  } catch (error) {
    console.error("Login error:", error);
    alert("Unable to sign in. Check your credentials and account approval.");
  }
};

/* GOOGLE LOGIN
   New Google accounts are recorded as pending, then immediately denied.
   Promote the user in Firestore by setting role='admin' and enabled=true. */
window.googleLogin = async function () {
  try {
    const provider = new GoogleAuthProvider();
    provider.setCustomParameters({ prompt: "select_account" });

    const credential = await signInWithPopup(auth, provider);
    const user = credential.user;
    const userRef = doc(db, "users", user.uid);
    const snapshot = await getDoc(userRef);

    if (!snapshot.exists()) {
      await setDoc(userRef, {
        fullName: user.displayName || "",
        email: user.email || "",
        role: "pending",
        enabled: false,
        authProvider: "google",
        photoURL: user.photoURL || "",
        createdAt: serverTimestamp()
      });
    }

    if (!(await isApprovedAdmin(user))) {
      await denyAccess("Google account recorded, but access is not approved. Set this user to role = admin and enabled = true in Firestore.");
      return;
    }

    sessionStorage.removeItem(LOGOUT_MARKER);
    window.location.replace("dashboard.html");
  } catch (error) {
    console.error("Google login error:", error);
    if (auth.currentUser) await signOut(auth);
    alert(error?.message || "Google sign-in failed.");
  }
};

/* MANUAL REGISTRATION
   Registration NEVER grants admin automatically. */
window.register = async function (event) {
  event.preventDefault();

  const fullName = document.getElementById("fullName").value.trim();
  const email = document.getElementById("registerEmail").value.trim().toLowerCase();
  const confirmEmail = document.getElementById("confirmEmail").value.trim().toLowerCase();
  const password = document.getElementById("registerPassword").value;
  const confirmPassword = document.getElementById("confirmPassword").value;

  if (email !== confirmEmail) {
    alert("Email addresses do not match.");
    return;
  }

  if (password !== confirmPassword) {
    alert("Passwords do not match.");
    return;
  }

  if (password.length < 6) {
    alert("Password must be at least 6 characters.");
    return;
  }

  try {
    const credential = await createUserWithEmailAndPassword(auth, email, password);
    const user = credential.user;

    await setDoc(doc(db, "users", user.uid), {
      fullName,
      email,
      role: "pending",
      enabled: false,
      authProvider: "password",
      createdAt: serverTimestamp()
    });

    await signOut(auth);
    alert("Registration successful. Your account is pending administrator approval.");
    window.location.replace("index.html");
  } catch (error) {
    console.error("Registration error:", error);
    alert(error?.message || "Registration failed.");
  }
};

window.logout = async function () {
  sessionStorage.setItem(LOGOUT_MARKER, "1");
  document.documentElement.style.visibility = "hidden";

  try {
    await signOut(auth);
  } catch (error) {
    console.error("Logout error:", error);
  } finally {
    window.location.replace("index.html");
  }
};

export async function logout() {
  sessionStorage.setItem(LOGOUT_MARKER, "1");
  document.documentElement.style.visibility = "hidden";

  try {
    await signOut(auth);
  } catch (error) {
    console.error("Logout error:", error);
  } finally {
    window.location.replace("index.html");
  }
}

export { isApprovedAdmin };
