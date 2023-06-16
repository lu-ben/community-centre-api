import express from 'express'
import bulletinController from './controller.js';

export const bulletinRouter = express.Router();

bulletinRouter.get('/', bulletinController.getBulletin)
bulletinRouter.post('/create', bulletinController.createBulletin)
bulletinRouter.post('/approve', bulletinController.approveBulletin)
bulletinRouter.post('/delete', bulletinController.deleteBulletin)
