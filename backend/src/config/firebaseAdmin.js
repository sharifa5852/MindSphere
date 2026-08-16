const { initializeApp, applicationDefault, getApps } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

if (!getApps().length) {
  initializeApp({
    credential: applicationDefault(),
  });
}

module.exports = getAuth();