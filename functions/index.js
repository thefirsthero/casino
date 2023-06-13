const admin = require("firebase-admin");
const functions = require("firebase-functions");
const faker = require("faker");

admin.initializeApp();

const db = admin.firestore();

/**
 * Generates a random name with a lottery theme.
 * @return {string} The generated random name.
 */
function generateRandomName() {
  // Generate a random name with a lottery theme
  const adjectives = ["Lucky", "Fortunate", "Winning", "Jackpot", "Golden"];
  const nouns = ["Ticket", "Numbers", "Chance", "Prize", "Millionaire"];

  const adjective = adjectives[Math.floor(Math.random() * adjectives.length)];
  const noun = nouns[Math.floor(Math.random() * nouns.length)];
  const suffix = faker.random.alpha({count: 3}).toLowerCase();

  return `${adjective} ${noun} ${suffix}`;
}

/**
 * Generates an array of 4 random numbers between 1 and 29.
 * @return {number[]} The array of generated random numbers.
 */
function generateRandomNumbers() {
  // Generate 4 random numbers between 1 and 29
  const numbers = [];
  while (numbers.length < 4) {
    const num = Math.floor(Math.random() * 29) + 1;
    if (!numbers.includes(num)) {
      numbers.push(num);
    }
  }
  return numbers;
}

/**
 * Cloud Function to populate the lotteryEvents collection in Firestore every
 * minute.
 * @param {functions.EventContext} context The event context.
 * @returns {Promise<void>} A promise that resolves when the population is
 *  complete.
 */
exports.populateLotteryEvents = functions.pubsub
    // Run every Tuesday, Thursday, & Sunday at
    // 21:00 (South African Standard Time)
    .schedule("00 21 * * 2,4,7")
    .timeZone("Africa/Johannesburg")
    .onRun(async (context) => {
      // Generate the data for the new entry
      const currentDateTime = admin.firestore.Timestamp.now().toDate();
      const name = generateRandomName();
      const winningNumbers = generateRandomNumbers();

      // Determine the day of the draw
      const daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday",
        "Thursday", "Friday", "Saturday"];
      const currentDay = daysOfWeek[currentDateTime.getDay()];

      // Create a new document in the 'lotteryEvents' collection
      const lotteryEvent = {
        date: currentDateTime,
        name: name,
        winningNumbers: winningNumbers,
        amountSoFar: 0, // Initialize the amount of money to 0
        dayOfDraw: currentDay, // Add the day of the draw
      };

      // Add the new document to the 'lotteryEvents' collection
      await db.collection("lotteryEvents").add(lotteryEvent);
      console.log("Lottery event added:", lotteryEvent);
      return null;
    });
