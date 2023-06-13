import db from '../../config/db.js'

const getEvents = async (req, res) => {
  try {
    const eventType = req.query.selectedType === 'All' ? undefined : req.query.selectedType
    const ageRange = req.query.selectedAgeRange === 'All' ? undefined : req.query.selectedAgeRange
    let filters = ''
    if (eventType && ageRange) {
      filters = `WHERE es.event_type = '${req.query.selectedType.toLowerCase()}' AND es.age_range = '${req.query.selectedAgeRange.toLowerCase()}'`
    } if (eventType && !ageRange) {
      filters = `WHERE es.event_type = '${req.query.selectedType.toLowerCase()}'`
    } if (!eventType && ageRange) {
      filters = `WHERE es.age_range = '${req.query.selectedAgeRange.toLowerCase()}'`
    }
    console.log(filters)
    const eventQuery = req.query.accountType === 'employee'
      ? `SELECT p.program_name AS title, e.facility_name AS subtitle, e.date FROM event e LEFT JOIN program p ON e.event_id = p.event_id WHERE instructed_by = ${Number(req.query.typeSpecificId)}`
      : `SELECT
          es.event_id AS id,
          es.date,
          es.subtitle,
          es.title,
          es.age_range AS age,
          es.event_type AS type,
          CASE WHEN count(esu2) >= es.capacity THEN true
          ELSE false
          END AS disabled
        FROM 
          (SELECT
            e.date,
            e.facility_name AS subtitle,
            e.event_id,
            e.capacity,
            e.age_range,
            e.event_type,
            CASE WHEN e.event_type = 'program' THEN p.program_name
            ELSE CONCAT(CONCAT(UPPER(LEFT(d.sport::text,1)), LOWER(RIGHT(d.sport::text,LENGTH(d.sport::text)-1))),' ', 'Drop-in') END AS title
            FROM (
              SELECT DISTINCT event_id
              FROM event
              EXCEPT
              SELECT DISTINCT event_id
              FROM event_sign_up
              WHERE client_id = ${req.query.typeSpecificId}) 
            AS usue
            LEFT JOIN event e ON usue.event_id = e.event_id
            LEFT JOIN program p ON e.event_id = p.event_id
            LEFT JOIN drop_in d ON d.event_id = e.event_id) AS es 
          LEFT JOIN event_sign_up esu2 ON es.event_id = esu2.event_id
          ${filters}
          GROUP BY 
            es.event_id,
            es.capacity,
            es.date,
            es.subtitle,
            es.title,
            es.event_type,
            es.age_range
          ORDER BY es.date`
    const events = await db.client.query(eventQuery)
    res.status(200).json({ events: events.rows })
  } catch (err) {
    console.log(err)
    res.status(500).json(err)
  }
}

const register = async (req, res) => {
  console.log(req.query)
  try {
    await db.client.query(`INSERT INTO event_sign_up (client_id, event_id) VALUES (${Number(req.query.typeSpecificId)}, ${Number(req.query.eventId)})`);
    res.status(200).json({})
  } catch (err) {
    console.log(err)
  }
}

export default {
  getEvents,
  register,
}

