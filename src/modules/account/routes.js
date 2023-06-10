import express from 'express'
import accountController from './controller.js';

export const accountRouter = express.Router();

accountRouter.get('/', accountController.login)
