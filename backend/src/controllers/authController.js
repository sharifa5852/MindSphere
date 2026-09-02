// const User = require("../models/User");

// const syncUser = async (req, res) => {
//   try {
//     // authMiddleware already verified the Firebase ID token before this
//     // function runs, so req.firebaseUser is trustworthy.
//     const firebaseUser = req.firebaseUser;

//     const uid = firebaseUser.uid;
//     const email = firebaseUser.email;

//     // Name comes from Flutter (collected during signup / Firebase profile).
//     const { name } = req.body;

//     if (!uid || !email) {
//       return res.status(400).json({
//         success: false,
//         message: "Firebase user information is incomplete.",
//       });
//     }

//     // Always look the user up by Firebase UID, never by name or email.
//     let user = await User.findOne({ firebaseUid: uid });

//     // -----------------------------
//     // User does not exist yet
//     // -----------------------------
//     if (!user) {
//       user = await User.create({
//         firebaseUid: uid,
//         name: name || "MindSphere User",
//         email: email,
//       });

//       return res.status(201).json({
//         success: true,
//         message: "User created successfully.",
//         user: {
//           id: user._id,
//           firebaseUid: user.firebaseUid,
//           name: user.name,
//           email: user.email,
//         },
//       });
//     }

//     // -----------------------------
//     // User already exists — keep it in sync
//     // -----------------------------
//     if (name && name.trim() !== "") {
//       user.name = name.trim();
//     }

//     user.email = email;

//     await user.save();

//     return res.status(200).json({
//       success: true,
//       message: "User synchronized successfully.",
//       user: {
//         id: user._id,
//         firebaseUid: user.firebaseUid,
//         name: user.name,
//         email: user.email,
//       },
//     });
//   } catch (error) {
//     console.error("User sync error:", error);

//     return res.status(500).json({
//       success: false,
//       message: "Failed to synchronize user.",
//     });
//   }
// };

// const getCurrentUser = async (req, res) => {
//   try {
//     // authMiddleware already verified the Firebase ID token.
//     const uid = req.firebaseUser.uid;

//     const user = await User.findOne({ firebaseUid: uid });

//     if (!user) {
//       return res.status(404).json({
//         success: false,
//         message: "No MongoDB profile found for this user yet.",
//       });
//     }

//     return res.status(200).json({
//       success: true,
//       user: {
//         id: user._id,
//         firebaseUid: user.firebaseUid,
//         name: user.name,
//         email: user.email,
//         photoURL: user.photoURL,
//         preferences: user.preferences,
//       },
//     });
//   } catch (error) {
//     console.error("Get current user error:", error);

//     return res.status(500).json({
//       success: false,
//       message: "Failed to fetch user.",
//     });
//   }
// };

// module.exports = {
//   syncUser,
//   getCurrentUser,
// };

const User = require("../models/User");

const syncUser = async (req, res) => {
  try {
    // authMiddleware already verified the Firebase ID token before this
    // function runs, so req.firebaseUser is trustworthy.
    const firebaseUser = req.firebaseUser;

    const uid = firebaseUser.uid;
    const email = firebaseUser.email;

    // Name comes from Flutter (collected during signup / Firebase profile).
    const { name } = req.body;

    if (!uid || !email) {
      return res.status(400).json({
        success: false,
        message: "Firebase user information is incomplete.",
      });
    }

    // Always look the user up by Firebase UID, never by name or email.
    let user = await User.findOne({ firebaseUid: uid });

    // -----------------------------
    // User does not exist yet
    // -----------------------------
    if (!user) {
      user = await User.create({
        firebaseUid: uid,
        name: name || "MindSphere User",
        email: email,
      });

      return res.status(201).json({
        success: true,
        message: "User created successfully.",
        user: {
          id: user._id,
          firebaseUid: user.firebaseUid,
          name: user.name,
          email: user.email,
        },
      });
    }

    // -----------------------------
    // User already exists — keep it in sync
    // -----------------------------
    if (name && name.trim() !== "") {
      user.name = name.trim();
    }

    user.email = email;

    await user.save();

    return res.status(200).json({
      success: true,
      message: "User synchronized successfully.",
      user: {
        id: user._id,
        firebaseUid: user.firebaseUid,
        name: user.name,
        email: user.email,
      },
    });
  } catch (error) {
    console.error("User sync error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to synchronize user.",
    });
  }
};

const getCurrentUser = async (req, res) => {
  try {
    // authMiddleware already verified the Firebase ID token.
    const uid = req.firebaseUser.uid;

    const user = await User.findOne({ firebaseUid: uid });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "No MongoDB profile found for this user yet.",
      });
    }

    return res.status(200).json({
      success: true,
      user: {
        id: user._id,
        firebaseUid: user.firebaseUid,
        name: user.name,
        email: user.email,
        photoURL: user.photoURL,
        preferences: user.preferences,
      },
    });
  } catch (error) {
    console.error("Get current user error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch user.",
    });
  }
};

const updateProfile = async (req, res) => {
  try {
    // authMiddleware already verified the Firebase ID token.
    const uid = req.firebaseUser.uid;
    const { name, notificationsEnabled, checkInTime, theme } = req.body;

    const user = await User.findOne({ firebaseUid: uid });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "No MongoDB profile found for this user yet.",
      });
    }

    if (name !== undefined) {
      if (typeof name !== "string" || name.trim() === "") {
        return res.status(400).json({
          success: false,
          message: "Name must be non-empty text.",
        });
      }
      user.name = name.trim();
    }

    if (notificationsEnabled !== undefined) {
      if (typeof notificationsEnabled !== "boolean") {
        return res.status(400).json({
          success: false,
          message: "notificationsEnabled must be true or false.",
        });
      }
      user.preferences.notificationsEnabled = notificationsEnabled;
    }

    if (checkInTime !== undefined) {
      const isValidTime =
        typeof checkInTime === "string" &&
        /^([01]\d|2[0-3]):[0-5]\d$/.test(checkInTime);

      if (!isValidTime) {
        return res.status(400).json({
          success: false,
          message: "checkInTime must be in HH:mm 24-hour format.",
        });
      }
      user.preferences.checkInTime = checkInTime;
    }

    if (theme !== undefined) {
      if (!["system", "light", "dark"].includes(theme)) {
        return res.status(400).json({
          success: false,
          message: "theme must be one of: system, light, dark.",
        });
      }
      user.preferences.theme = theme;
    }

    await user.save();

    return res.status(200).json({
      success: true,
      message: "Profile updated successfully.",
      user: {
        id: user._id,
        firebaseUid: user.firebaseUid,
        name: user.name,
        email: user.email,
        photoURL: user.photoURL,
        preferences: user.preferences,
      },
    });
  } catch (error) {
    console.error("Update profile error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update profile.",
    });
  }
};

module.exports = {
  syncUser,
  getCurrentUser,
  updateProfile,
};