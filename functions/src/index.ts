// updatePlantHealth.ts
import admin from 'firebase-admin';
import { MongoClient } from 'mongodb';
import dayjs from 'dayjs';
import dotenv from 'dotenv';

dotenv.config();

// Initialize Firebase Admin
admin.initializeApp({
    credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_CREDENTIAL_JSON!)),
});

const db = admin.firestore();

// Initialize MongoDB
const mongoClient = new MongoClient(process.env.MONGODB_URI!);

async function updatePlantHealth() {
    await mongoClient.connect();
    const mongoDb = mongoClient.db('verdantia');
    const plantsCollection = mongoDb.collection('plants');

    const plotsSnapshot = await db.collection('plots').get();

    for (const doc of plotsSnapshot.docs) {
        const plotData = doc.data();
        const plotIndex = plotData.index;
        const lastWater = plotData.lastWater;
        const lastSunlight = plotData.lastSunlight;

        if (!lastWater || !lastSunlight) continue;

        const plant = await plantsCollection.findOne({ plotIndex });
        if (!plant) continue;

        const now = dayjs();
        const lastWaterTime = dayjs(lastWater.toDate());
        const lastSunlightTime = dayjs(lastSunlight.toDate());
        const daysSinceCare = Math.min(
            now.diff(lastWaterTime, 'day'),
            now.diff(lastSunlightTime, 'day')
        );

        let newHp = plant.hp;
        const age = plant.age || 100;

        if (daysSinceCare <= 2) {
            newHp += 5 * (2 - daysSinceCare);
        } else {
            newHp -= 3 * (daysSinceCare - 2);
        }

        newHp = Math.min(newHp, age);
        newHp = Math.max(newHp, 0);

        await plantsCollection.updateOne(
            { plotIndex },
            { $set: { hp: newHp } }
        );

        console.log(`Updated plant at plot ${plotIndex}: HP = ${newHp}`);
    }

    await mongoClient.close();
}

updatePlantHealth().catch(console.error);