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
    .schedule("30 20 * * 2,4,7")
    .timeZone("Africa/Johannesburg")
    .onRun(async (context) => {
      // Generate the data for the new entry
      const currentDate = new Date();
      // eslint-disable-next-line max-len
      const currentDay = currentDate.toLocaleDateString("en-US", {weekday: "long"});

      // Determine the next draw day based on the current day
      let nextDrawDay;
      if (currentDay === "Tuesday") {
        nextDrawDay = "Thursday";
      } else if (currentDay === "Thursday") {
        nextDrawDay = "Sunday";
      } else if (currentDay === "Sunday") {
        nextDrawDay = "Tuesday";
      } else {
        console.log("No lottery event for the current day:", currentDay);
        return null;
      }

      // Determine the future date of the next draw day
      const nextDrawDate = getNextDrawDate(currentDate, nextDrawDay);

      /**
       * Calculates the future date of the next draw day based on
       * the current date.
       * @param {Date} currentDate The current date.
       * @param {string} nextDrawDay The next draw day.
       * @return {Date} The future date of the next draw day.
       */
      function getNextDrawDate(currentDate, nextDrawDay) {
        const daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday",
          "Thursday", "Friday", "Saturday"];
        // eslint-disable-next-line max-len
        const currentDayIndex = daysOfWeek.indexOf(currentDate.toLocaleDateString("en-US", {weekday: "long"}));
        const nextDrawDayIndex = daysOfWeek.indexOf(nextDrawDay);
        const daysToAdd = (nextDrawDayIndex + 7 - currentDayIndex) % 7;
        const nextDrawDate = new Date(currentDate);
        nextDrawDate.setDate(currentDate.getDate() + daysToAdd);
        return nextDrawDate;
      }

      // Generate the random numbers based on the next draw day
      let winningNumbers;
      if (nextDrawDay === "Tuesday") {
        winningNumbers = generateRandomNumbers(4, 1, 29);
      } else if (nextDrawDay === "Thursday") {
        winningNumbers = generateRandomNumbers(3, 1, 39);
      } else if (nextDrawDay === "Sunday") {
        winningNumbers = generateRandomNumbers(2, 1, 49);
      }

      // Generate the name for the new entry
      const name = generateRandomName();

      // Create a new document in the 'lotteryEvents' collection
      const lotteryEvent = {
        date: admin.firestore.Timestamp.fromDate(nextDrawDate),
        name: name,
        winningNumbers: winningNumbers,
        amountSoFar: 0, // Initialize the amount of money to 0
        dayOfDraw: nextDrawDay, // Add the next draw day
        minRange: 1, // Minimum value of the range
        // eslint-disable-next-line max-len
        maxRange: winningNumbers.length === 4 ? 29 : winningNumbers.length === 3 ? 39 : 49,
        isOngoing: true, // Set the isOngoing field to true
      };

      const lotteryEventsRef = db.collection(lotteryEventsCollection);
      const querySnapshot = await lotteryEventsRef
          .orderBy("date", "desc")
          .limit(1)
          .get();

      if (!querySnapshot.empty) {
        const previousEvent = querySnapshot.docs[0];

        // Check if there's a matching document in the gamesPlayed collection
        const gamesPlayedRef = db.collection("gamesPlayed");
        const matchingDocuments = await gamesPlayedRef
            .where("lotteryEventID", "==", previousEvent.id)
            .where("numbersPlayed",
                "array-contains-any", previousEvent.data().winningNumbers)
            .get();

        // Update the correctNumbers field in the matching documents
        matchingDocuments.forEach(async (doc) => {
          const numbersPlayed = doc.data().numbersPlayed;
          const matchingNumbers = numbersPlayed.filter((num) =>
            previousEvent.data().winningNumbers.includes(num));
          const correctNumbers = doc.data().correctNumbers || [];
          const updatedCorrectNumbers = [
            ...new Set(correctNumbers.concat(matchingNumbers))];
          await doc.ref.update({correctNumbers: updatedCorrectNumbers});
        });

        await previousEvent.ref.update({isOngoing: false});
      }

      // Add the new document to the 'lotteryEvents' collection
      await lotteryEventsRef.add(lotteryEvent);
      console.log("Lottery event added:", lotteryEvent);
      return null;
    });
