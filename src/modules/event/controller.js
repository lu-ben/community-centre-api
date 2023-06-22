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
              FROM event WHERE DATE(date) > DATE(NOW())
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

const getPastEvents = async (req, res) => {
  const displayColumns = req.query.displayColumns && req.query.displayColumns.length > 0 ? `${req.query.displayColumns.join(',')},` : ''
  try {
    const eventQuery =
      `SELECT
          ${displayColumns}
          pe.title 
      FROM 
        (
          (SELECT
            CASE WHEN e.event_type = 'program' THEN p.program_name
            ELSE CONCAT(CONCAT(UPPER(LEFT(d.sport::text,1)), LOWER(RIGHT(d.sport::text,LENGTH(d.sport::text)-1))),' ', 'Drop-in') END AS title,
            date,
            facility_name,
            event_type::varchar,
            age_range::varchar
          FROM (SELECT event_id FROM event_sign_up WHERE client_id = ${req.query.typeSpecificId}) AS sue
          LEFT JOIN event e ON sue.event_id = e.event_id
          LEFT JOIN program p ON e.event_id = p.event_id
          LEFT JOIN drop_in d ON d.event_id = e.event_id
          WHERE  DATE(e.date) < DATE(NOW()))
      UNION ALL
        (SELECT
          gt.activity AS title,
          date,
          ud.facility_name,
          'unscheduled' AS event_type,
          'all' AS age_range
        FROM (SELECT * FROM go_to_unscheduled_drop_in WHERE client_id = ${req.query.typeSpecificId} AND DATE(date) < DATE(now())) AS gt
        LEFT JOIN unscheduled_drop_in ud ON gt.activity = ud.activity))
      AS pe
      ORDER BY date DESC`
    const events = await db.client.query(eventQuery)
    res.status(200).json({ events: events.rows })
  } catch (err) {
    console.log(err)
    res.status(500).json(err)
  }
}

const getAllUpcomingEvents = async (req, res) => {
  try {
    const events = await db.client.query(`
      SELECT 
        e.event_id AS id,
        e."age_range",
        e."date",
        e.capacity,
        e.facility_name AS subtitle,
        e."event_type",
        COUNT(esu.client_id) AS sign_up_count,
        CASE WHEN e.event_type = 'program' THEN p.program_name
          ELSE CONCAT(CONCAT(UPPER(LEFT(d.sport::text,1)), LOWER(RIGHT(d.sport::text,LENGTH(d.sport::text)-1))),' ', 'Drop-in') 
          END AS title,
        CASE WHEN e.capacity > COUNT(esu.client_id) THEN false
          WHEN e.capacity <= COUNT(esu.client_id) THEN true
          END AS is_full
        FROM event e
        LEFT JOIN event_sign_up esu ON e.event_id = esu.event_id 
        LEFT JOIN program p ON p.event_id = e.event_id
        LEFT JOIN drop_in d ON d.event_id = e.event_id 
        WHERE DATE(e.date) > DATE(NOW())
        GROUP BY e.event_id, e."age_range", e."date", e.capacity, e.facility_name, e."event_type", p.program_name, d.sport
        ORDER BY e.date`)
    res.status(200).json({ events: events.rows })
  } catch (err) {
    console.log(err)
    res.status(500).json(err)
  }
}

const getEventStats = async (req, res) => {
  try {
    const eventStats = await db.client.query(`
      SELECT 
        ROUND(AVG(esu.client_count), 0) AS average,
        MAX(esu.client_count) AS max,
        MIN(esu.client_count) AS min
      FROM (SELECT e.event_id, count(client_id) AS client_count
      FROM event e 
      LEFT JOIN event_sign_up esu ON esu.event_id = e.event_id 
      GROUP BY e.event_id
      HAVING e."age_range" = '${req.query.age}' AND e."event_type" = '${req.query.type}') AS esu`)
    res.status(200).json({ eventStats: eventStats.rows[0] })
  } catch (err) {
    console.log(err)
    res.status(500).json(err)
  }
}

const getClientEventStats = async (_, res) => {
  try {
    const promiseArr = [
      db.client.query(`
      SELECT csu.age_range, ROUND(AVG(csu.count)) AS count
      FROM 
        (SELECT
          c.client_id,
          COUNT(c.client_id),
          CASE 
            WHEN c.age <= 11 THEN 'child'
            WHEN c.age > 11 AND c.age < 18 THEN 'youth'
            WHEN c.age >= 18 THEN 'adult'
          END AS age_range
        FROM account a, client c, event_sign_up esu
        WHERE a.username = c.username
        AND a."account_type" = 'client'
        AND esu.client_id = c.client_id 
        GROUP BY c.client_id) AS csu 
      GROUP BY csu.age_range`),
      db.client.query(`
        SELECT esu1.client_id, ac.first_name, ac.last_name 
        FROM event_sign_up AS esu1
        LEFT JOIN client c ON c.client_id = esu1.client_id 
        LEFT JOIN account ac ON ac.username = c.username
        WHERE NOT EXISTS (
          (SELECT event_id FROM event)
          EXCEPT
          (SELECT esu2.event_id FROM event_sign_up esu2 WHERE esu1.client_id = esu2.client_id))
        GROUP BY esu1.client_id, ac.first_name, ac.last_name`)
    ]
    const [avgSignUpPerAgeGroup, accountWithAllSignedUp] = await Promise.all(promiseArr)
    res.status(200).json({
      avgSignUpPerAgeGroup: avgSignUpPerAgeGroup.rows,
      accountWithAllSignedUp: accountWithAllSignedUp.rows,
    })
  } catch (err) {
    console.log(err)
  }
}

const deleteEvent = async (req, res) => {
  try {
    if (req.query.eventId) {
      const result = await db.client.query(`DELETE FROM event WHERE event_id = ${Number(req.query.eventId)} RETURNING *`);
      res.status(200).json({ event: result.rows[0] })
    }
  } catch (err) {
    console.log(err)
    res.status(500).json(err)
  }
}

const register = async (req, res) => {
  try {
    await db.client.query(`INSERT INTO event_sign_up (client_id, event_id) VALUES (${Number(req.query.typeSpecificId)}, ${Number(req.query.eventId)})`);
    res.status(200).json({})
  } catch (err) {
    console.log(err)
  }
}

export default {
  getEvents,
  getPastEvents,
  getEventStats,
  getClientEventStats,
  getAllUpcomingEvents,
  register,
  deleteEvent,
}

