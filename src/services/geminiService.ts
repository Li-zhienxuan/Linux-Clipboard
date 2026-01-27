import { GoogleGenAI, Type } from "@google/genai";

// 辅助函数：获取 API Key
const getApiKey = async (): Promise<string> => {
  // Electron 环境：从存储获取 API Key
  if (typeof window !== 'undefined' && (window as any).electronAPI?.isElectron) {
    const apiKey = await (window as any).electronAPI.getApiKey();
    if (apiKey) return apiKey;
  }

  // Web 环境或降级：使用环境变量
  if (typeof process !== 'undefined' && process.env?.API_KEY) {
    return process.env.API_KEY;
  }

  throw new Error('Gemini API Key not configured. AI features will be disabled. You can set it in settings.');
};

export const analyzeImage = async (base64Image: string): Promise<{ description: string; tags: string[] }> => {
  const apiKey = await getApiKey();
  const ai = new GoogleGenAI({ apiKey });
  try {
    const response = await ai.models.generateContent({
      model: "gemini-3-flash-preview",
      contents: [
        {
          parts: [
            { text: "Describe this image content for a searchable clipboard manager. Provide a concise 1-sentence description and 5-8 relevant keywords/tags. Return the output in JSON format with 'description' and 'tags' fields." },
            {
              inlineData: {
                mimeType: "image/png",
                data: base64Image.split(',')[1] || base64Image
              }
            }
          ]
        }
      ],
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            description: { type: Type.STRING },
            tags: {
              type: Type.ARRAY,
              items: { type: Type.STRING }
            }
          },
          required: ["description", "tags"]
        }
      }
    });

    const result = JSON.parse(response.text);
    return result;
  } catch (error) {
    console.error("Gemini Image Analysis failed:", error);
    return {
      description: "Unprocessed image",
      tags: ["image"]
    };
  }
};

export const suggestTags = async (text: string): Promise<string[]> => {
  const apiKey = await getApiKey();
  const ai = new GoogleGenAI({ apiKey });
  try {
    const response = await ai.models.generateContent({
      model: "gemini-3-flash-preview",
      contents: `Suggest 3-5 keywords for this text clipping to help categorize it: "${text.substring(0, 500)}"`,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.ARRAY,
          items: { type: Type.STRING }
        }
      }
    });
    return JSON.parse(response.text);
  } catch (error) {
    return ["text"];
  }
};