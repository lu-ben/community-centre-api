import express from 'express'
import dotenv from 'dotenv'
import db from './config/db.js'

import { accountRouter } from './modules/account/routes.js'
import { dashboardRouter } from './modules/dashboard/routes.js';

dotenv.config();
const app = express();

const startServer = () => {
  app.listen(process.env.API_PORT, () => console.log(`[#] Server started on port ${process.env.API_PORT} [#]`))
  app.use((req, res, next) => {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.header(
      'Access-Control-Allow-Headers',
      'Origin, X-Requested-With, Content-Type, Accept'
    );
    next();
  })
  app.use('/account', accountRouter)
  app.use('/dashboard', dashboardRouter)
}

const main = async () => {
  await db.client.connect()
    .then(() => {
      console.log(`[#] Connected to Database ${process.env.DB_NAME} on port ${process.env.DB_PORT} [#]`);
      startServer();
    })
    .catch((err) => { console.log(`[#] Error connecting to database: ${err} [#]`) });
}

main();