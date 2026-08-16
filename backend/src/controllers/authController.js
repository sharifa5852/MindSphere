const User = require("../models/User");

const syncUser = async (req, res) => {
  try {
    const { name } = req.body;
    const { uid, email } = req.firebaseUser;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Your Firebase account does not have an email address.",
      });
    }

    let user = await User.findOne({ firebaseUid: uid });

    if (!user) {
      if (!name?.trim()) {
        return res.status(400).json({
          success: false,
          message: "Name is required when creating a user profile.",
        });
      }

      user = await User.create({
        firebaseUid: uid,
        name: name.trim(),
        email,
      });
    } else if (name?.trim()) {
      user.name = name.trim();
      await user.save();
    }

    return res.status(user.isNew ? 201 : 200).json({
      success: true,
      message: "User profile is ready.",
      user,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Could not sync user profile.",
    });
  }
};

const getCurrentUser = async (req, res) => {
  try {
    const user = await User.findOne({
      firebaseUid: req.firebaseUser.uid,
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User profile not found. Call POST /api/auth/sync first.",
      });
    }

    return res.json({
      success: true,
      user,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Could not get user profile.",
    });
  }
};

module.exports = { syncUser, getCurrentUser };