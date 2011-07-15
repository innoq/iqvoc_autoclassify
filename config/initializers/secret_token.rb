# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
if Iqvoc::AutoClassify.const_defined?(:Application)
  Iqvoc::AutoClassify::Application.config.secret_token = '843652ec380bb29fecec54d6f09020c372f9bf9a737e134ba29bdb5672e498dcfb5ed73e55f645c34cf9afbfb0b684ee3433e7288b00f447cca92445ed5406b0'
end
