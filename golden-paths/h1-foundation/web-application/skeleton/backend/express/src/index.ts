import express from "express";
import helmet from "helmet";
import cors from "cors";

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());

app.get("/health", (_req, res) => res.json({ status: "healthy" }));
app.get("/", (_req, res) => res.json({ service: "${{values.appName}}", version: "0.1.0" }));

const port = process.env.PORT || 3001;
app.listen(port, () => console.log(`Server running on port ${port}`));
