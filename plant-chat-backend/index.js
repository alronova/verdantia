// // index.js
// import express from 'express';
// import cors from 'cors';
// import dotenv from 'dotenv';
// import { OpenAI } from 'openai';

// dotenv.config();

// const app = express();
// app.use(cors());
// app.use(express.json());

// const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

// app.post('/chat', async (req, res) => {
//     const { messages } = req.body;

//     // inject system message at the beginning
//     const systemMessage = {
//         role: 'system',
//         content: 'You are a helpful and knowledgeable plant care assistant. Provide expert advice on plant health, watering, sunlight, soil, and related topics in a friendly, clear way.',
//     };

//     try {
//         const response = await openai.chat.completions.create({
//             model: 'gpt-3.5-turbo',
//             messages: [systemMessage, ...messages], // Inject system message
//         });

//         res.json({ reply: response.choices[0].message.content });
//     } catch (err) {
//         console.error(err);
//         res.status(500).json({ error: 'AI request failed' });
//     }
// });


// export default app;

import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import axios from 'axios';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;
const MODEL = 'mistralai/mistral-7b-instruct'; // You can change this to another free model

app.post('/chat', async (req, res) => {
    const { messages } = req.body;

    // Inject system prompt
    const systemMessage = {
        role: 'system',
        content: 'You are a helpful and knowledgeable plant care assistant. Provide expert advice on plant health, watering, sunlight, soil, and related topics in a friendly, clear way.',
    };

    try {
        const response = await axios.post(
            'https://openrouter.ai/api/v1/chat/completions',
            {
                model: MODEL,
                messages: [systemMessage, ...messages],
            },
            {
                headers: {
                    'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
                    'Content-Type': 'application/json',
                },
            }
        );

        const reply = response.data.choices[0].message.content;
        res.json({ reply });
    } catch (err) {
        console.error(err.response?.data || err.message);
        res.status(500).json({ error: 'AI request failed' });
    }
});

export default app;
