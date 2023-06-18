import db from '../../config/db.js'

const getEquipment = async (req, res) => {
    try {
        const { facility, equipment } = req.query
        let filters = `WHERE equipment_id NOT IN (SELECT equipment_id FROM borrow_equipment) ${facility || equipment ? 'AND ' : ``}`;
        // let filters = '';
        if (facility && !equipment) {
            filters += `facility_name = '${facility}'`
        } else if (facility && equipment) {
            filters += `facility_name = '${facility}' AND equipment_name LIKE '${equipment}'`
        } else if (!facility && equipment) {
            filters += `equipment_name LIKE '${equipment}'`
        }

        const query = `SELECT
        equipment_name AS title,
        facility_name AS subtitle,
        equipment_id AS date
        FROM equipment ${filters}
        `

        const equipmentData = await db.client.query(query);
        res.status(200).json({ equipment: equipmentData.rows });
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