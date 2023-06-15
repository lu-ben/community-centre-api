import express from 'express';
import announcementController from './controller.js';

export const announcementRouter = express.Router();

announcementRouter.get('/', announcementController.getAnnouncement)
announcementRouter.get('/getOptions', announcementController.getAnnouncementOptions)
announcementRouter.post('/createAnnouncement', announcementController.createAnnouncement)
