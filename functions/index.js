const admin = require("firebase-admin");
const functions = require("firebase-functions");
const faker = require("faker");

admin.initializeApp();

const db = admin.firestore();
const lotteryEventsCollection = "lotteryEvents";

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
 * Generates an array of random numbers within the specified range.
 * @param {number} count The number of random numbers to generate.
 * @param {number} min The minimum value of the range.
 * @param {number} max The maximum value of the range.
 * @return {number[]} The array of generated random numbers.
 */
function generateRandomNumbers(count, min, max) {
  const numbers = [];
  while (numbers.length < count) {
    const num = Math.floor(Math.random() * (max - min + 1)) + min;
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
    // Run every Tuesday, Thursday, & Sunday at 20:30 (South African
    //  Standard Time)
    .schedule("30 20 * * 2,4,7")
    .timeZone("Africa/Johannesburg")
    .onRun(async (context) => {
      // Generate the data for the new entry
      const currentDateTime = admin.firestore.Timestamp.now().toDate();
      const name = generateRandomName();

      // Determine the day of the draw
      const daysOfWeek = [
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
      ];
      const currentDay = daysOfWeek[currentDateTime.getDay()];

      // Generate the random numbers based on the day of the draw
      let winningNumbers;
      if (currentDay === "Tuesday") {
        winningNumbers = generateRandomNumbers(4, 1, 29);
      } else if (currentDay === "Wednesday") {
        winningNumbers = generateRandomNumbers(3, 1, 39);
      } else if (currentDay === "Thursday") {
        winningNumbers = generateRandomNumbers(2, 1, 49);
      } else {
        console.log("No lottery event for the current day:", currentDay);
        return null;
      }

      // Create a new document in the 'lotteryEvents' collection
      const lotteryEvent = {
        date: currentDateTime,
        name: name,
        winningNumbers: winningNumbers,
        amountSoFar: 0, // Initialize the amount of money to 0
        dayOfDraw: currentDay, // Add the day of the draw
        minRange: 1, // Minimum value of the range
        // Maximum value of the range
        // eslint-disable-next-line max-len
        maxRange:
          // eslint-disable-next-line max-len
          winningNumbers.length === 4 ? 29 : winningNumbers.length === 3 ? 39 : 49, // eslint-disable-next-line max-len
        isOngoing: true, // Set the isOngoing field to true
      };

      const lotteryEventsRef = db.collection(lotteryEventsCollection);
      const querySnapshot = await lotteryEventsRef
          .orderBy("date", "desc")
          .limit(1)
          .get();
      if (!querySnapshot.empty) {
        const previousEvent = querySnapshot.docs[0];
        await previousEvent.ref.update({isOngoing: false});
      }

      // Add the new document to the 'lotteryEvents' collection
      await lotteryEventsRef.add(lotteryEvent);
      console.log("Lottery event added:", lotteryEvent);
      return null;
    });
