import express from 'express'
import dashboardController from './controller.js';

export const dashboardRouter = express.Router();

dashboardRouter.get('/', dashboardController.getDashboard)
