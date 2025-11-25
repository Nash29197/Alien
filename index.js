const { spawn } = require("child_process")

console.log("🚀 Starting Discord Bot...")
console.log("📋 Checking environment variables...")

// Debug: Show what environment variables are available
console.log("Available environment variables:")
console.log("- DISCORD_TOKEN:", process.env.DISCORD_TOKEN ? "✅ Set" : "❌ Missing")
console.log("- CLIENT_ID:", process.env.CLIENT_ID ? "✅ Set" : "❌ Missing")

// Check if required environment variables are set
if (!process.env.DISCORD_TOKEN || process.env.DISCORD_TOKEN.trim() === "") {
  console.error("❌ DISCORD_TOKEN environment variable is required!")
  console.log("📝 Please add your Discord bot token to the Secrets tab in Replit")
  console.log("🔑 Secret name should be exactly: DISCORD_TOKEN")
  process.exit(1)
}

if (!process.env.CLIENT_ID || process.env.CLIENT_ID.trim() === "") {
  console.error("❌ CLIENT_ID environment variable is required!")
  console.log("📝 Please add your Discord application client ID to the Secrets tab in Replit")
  console.log("🔑 Secret name should be exactly: CLIENT_ID")
  process.exit(1)
}

console.log("✅ All environment variables are set!")
console.log("🤖 Starting bot process...")

// Start the bot
const bot = spawn("node", ["bot.js"], {
  stdio: "inherit",
  env: process.env,
})

bot.on("close", (code) => {
  console.log(`Bot process exited with code ${code}`)
  if (code !== 0) {
    console.log("🔄 Restarting bot in 5 seconds...")
    setTimeout(() => {
      process.exit(1) // Let Replit restart the process
    }, 5000)
  }
})

// Keep the process alive
process.on("SIGINT", () => {
  console.log("🛑 Shutting down bot...")
  bot.kill()
  process.exit(0)
})
