import express from 'express'
import equipmentController from './controller.js';

export const equipmentRouter = express.Router();

equipmentRouter.get('/', equipmentController.getEquipment);