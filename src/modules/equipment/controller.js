import db from '../../config/db.js'

const getEquipment = async (req, res) => {
    try {

        // TODO: query for whether equipment is rented
        const isRentedQuery = `SELECT * FROM borrow_equipment WHERE equipment_id = '${req.query.equipment_id}`

        let filters = '';
        if (req.query.facility && !req.query.equipment) {
            filters = `WHERE facility_name LIKE '${req.query.facility}'`
        } else if (req.query.facility && req.query.equipment) {
            filters = `WHERE facility_name LIKE '${req.query.facility}' AND equipment_name LIKE '${req.query.equipment}'`
        } else if (!req.query.facility && req.query.equipment) {
            filters = `WHERE equipment_name LIKE '${req.query.equipment}'`
        }
        const query = `SELECT
        equipment_name AS title,
        facility_name AS subtitle,
        equipment_id AS date
        FROM equipment ${filters}
        `
        const equipment = await db.client.query(query);
        // console.log(equipment.rows);
        res.status(200).json({ equipment: equipment.rows });
    } catch (err) {
        console.log(err);
        res.status(500).error(err);
    }
}

const getEquipmentOptions = async (req, res) => {
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

    const client_id = req.query.client_id;
    const equipment_id = req.query.equipment_id;

    try {
        await db.client.query(`INSERT INTO borrow_equipment (client_id, equipment_id, borrow_date, return_date) VALUES ('${client_id}', '${equipment_id}', CURRENT_TIMESTAMP, NULL)`);
        res.status(200).json({});
    } catch (err) {
        console.log(err);
    }
}

export default {
    getEquipment,
    getEquipmentOptions,
    rentEquipment
}