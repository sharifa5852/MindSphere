const firebaseAuth = require("../config/firebaseAdmin");

const authenticateUser = async (req, res, next) => {
  try {
    const authorizationHeader = req.headers.authorization;

    if (!authorizationHeader?.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Authorization token is missing or invalid.",
      });
    }

    const idToken = authorizationHeader.split("Bearer ")[1];
    req.firebaseUser = await firebaseAuth.verifyIdToken(idToken);

    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Unauthorized: invalid or expired Firebase token.",
    });
  }
};

module.exports = authenticateUser;