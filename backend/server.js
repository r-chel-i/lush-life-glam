import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import * as Survey from "./survey.js"

dotenv.config();
const app = express();

app.use(cors({ origin: "*" }));
app.use(express.json());

app.get("/health", (req, res) => {
    res.json({ ok: true });
});

app.get("/survey/:id", async (req, res) => {
    try {
        const surveyId = req.params.id;
        const survey = await Survey.getSurvey(surveyId);
        res.status(200).json(survey);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Failed to fetch survey" });
    }
});

// submit survey response 
// if fail, we would need to handle in calling method to automatically confirm that submission DID NOT happen
// if successful, user gets reward
app.post("/survey/:collectorId/submit", async (req, res) => {
    try {
        const collectorId = req.params.collectorId;
        const answers = req.body; 

        const result = await Survey.submitSurvey(collectorId, answers);

        if (result.status === 201 || result.status === 200) {
            // 201 = created, 200 = ok
            res.status(200).json({
                success: true,
                responseId: result.data.id // ID of the submitted response
            });
        } else {
            res.status(result.status).json({
                success: false,
                data: result.data
            });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, error: "Submission failed" });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Backend listening on port ${PORT}`));
