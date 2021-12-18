importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDn2lwTWqP32mcv-0IoEX-rdt6Df_cvVd0",
  authDomain: "working-project-f479c.firebaseapp.com",
  projectId: "working-project-f479c",
  storageBucket: "working-project-f479c.appspot.com",
  messagingSenderId: "742561613196",
  appId: "1:742561613196:web:22560f800ce4542dd742a9",
  measurementId: "G-RZ5GPE3CJV"
});

// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});