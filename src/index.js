import express from 'express'
import dotenv from 'dotenv'
import db from './config/db.js'

import { accountRouter } from './modules/account/routes.js'
import { dashboardRouter } from './modules/dashboard/routes.js';
import { eventRouter } from './modules/event/routes.js';
import { announcementRouter } from './modules/announcement/routes.js';
import { bulletinRouter } from './modules/bulletin/routes.js';
import { equipmentRouter } from './modules/equipment/routes.js';

dotenv.config();
const app = express();

const startServer = () => {
  app.listen(process.env.API_PORT, () => console.log(`[#] Server started on port ${process.env.API_PORT} [#]`))
  app.use((_, res, next) => {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.header(
      'Access-Control-Allow-Headers',
      'Origin, X-Requested-With, Content-Type, Accept'
    );
    next();
  })
  app.use('/account', accountRouter)
  app.use('/dashboard', dashboardRouter)
  app.use('/event', eventRouter)
  app.use('/announcement', announcementRouter)
  app.use('/bulletin', bulletinRouter)
  app.use('/rental', equipmentRouter)
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
