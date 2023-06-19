import db from '../../config/db.js'

const getEquipment = async (req, res) => {
	try {
		const { facility, equipment } = req.query
		let filters = '';

		if (facility && facility !== 'All' && !equipment) {
			filters += `WHERE e.facility_name = '${facility}'`
		} else if (facility && facility !== 'All' && equipment) {
			filters += `WHERE e.facility_name = '${facility}' AND LOWER(e.equipment_name) LIKE '%${equipment}%'`
		} else if (facility === 'All' && equipment) {
			filters += `WHERE LOWER(e.equipment_name) LIKE '%${equipment}%'`
		}

		const equipmentData = await db.client.query(
			`SELECT
				e.equipment_name AS title,
				e.facility_name AS subtitle,
				e.equipment_id AS id,
				EXISTS (SELECT * FROM borrow_equipment be WHERE be.equipment_id = e.equipment_id AND be.return_date is null) AS disabled
				FROM equipment e
				${filters}`);
		res.status(200).json({ equipment: equipmentData.rows });
	} catch (err) {
		console.log(err);
		res.status(500).json(err);
	}
}

const getEquipmentOptions = async (_, res) => {
	try {
		const facilityOptions = await db.client.query(`SELECT facility_name FROM facility`);
		const optionArr = facilityOptions.rows.map((option) => option.facility_name)
		res.status(200).json({ facilityOptions: optionArr })
	} catch (err) {
		console.log(err);
		res.status(500).json(err);
	}
}

const rentEquipment = async (req, res) => {
	try {
		const result = await db.client.query(
			`WITH inserted_reservation AS (
				INSERT INTO borrow_equipment (client_id, equipment_id) VALUES (${req.query.client_id}, ${req.query.equipment_id}) RETURNING *
			) SELECT e.equipment_id, e.equipment_name 
				FROM inserted_reservation 
				LEFT JOIN equipment e ON inserted_reservation.equipment_id = e.equipment_id;`);
		res.status(200).json({ name: result.rows[0].equipment_name, id: result.rows[0].equipment_id });
	} catch (err) {
		console.log(err);
		res.status(500).json(err)
	}
}

export default {
	getEquipment,
	getEquipmentOptions,
	rentEquipment
}