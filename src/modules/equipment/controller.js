import db from '../../config/db.js'

const getEquipment = async (req, res) => {

    // const {equipment, facility} = req.query;

    try {
        // console.log(req.query.facility);
        let filters = '';
        if (req.query.facility && !req.query.equipment) {
            filters = `WHERE facility_name LIKE '${req.query.facility}'`
        } else if (req.query.facility && req.query.equipment) {
            filters = `WHERE facility_name LIKE '${req.query.facility}' AND equipment_name LIKE '${req.query.equipment}'`
        } else if (!req.query.facility && req.query.equipment) {
            filters = `WHERE equipment_name LIKE '${req.query.equipment}'`
        }
        // console.log(filters);
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

export default {
    getEquipment,
    getEquipmentOptions
}