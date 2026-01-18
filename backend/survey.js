import fetch from "node-fetch";

const BASE_URL = "https://api.surveymonkey.com/v3";
const TOKEN = process.env.SURVEYMONKEY_TOKEN;

// get survey

export async function getSurvey(id) {
    const res = await fetch(`${BASE_URL}/surveys/${id}`, {
        headers:
            {"Authorization": `Bearer ${TOKEN}`,
            "Content-Type": "application/json"}
    });
    return res.json();
}

// submit survey 
// if successful, can extract response id and check if submitted
export async function submitSurvey(collectorId, answers) {
    const res = await fetch(`${BASE_URL}/collectors/${collectorId}/responses`, {
        method: "POST",
        headers: {
            "Authorization": `Bearer ${TOKEN}`,
            "Content-Type": "application/json"
        },
        body: JSON.stringify({pages: answers})
    });

    const data = await res.json();
    return {
        status: res.status,
        data
    };
}