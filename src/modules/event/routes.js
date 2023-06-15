import express from 'express'
import eventController from './controller.js';

export const eventRouter = express.Router();

eventRouter.get('/', eventController.getEvents)
eventRouter.get('/past', eventController.getPastEvents)
eventRouter.post('/register', eventController.register)