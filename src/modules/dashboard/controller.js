import db from '../../config/db.js'
import { ERROR } from '../../utils/enum.js'

const getDashboard = async (req, res) => {

  if (!req.query.accountType || !req.query.typeSpecificId) {
    res.status(400).json({ error: { message: ERROR.TID_NF } })
    return
  }

  const eventQuery = req.query.accountType === 'employee'
    ? `SELECT p.program_name AS title, e.facility_name AS subtitle, e.date FROM event e LEFT JOIN program p ON e.event_id = p.event_id WHERE instructed_by = ${Number(req.query.typeSpecificId)}`
    : `SELECT
        e.date,
        e.facility_name AS subtitle,
        CASE WHEN e.event_type = 'program' THEN p.program_name
        ELSE CONCAT(CONCAT(UPPER(LEFT(d.sport::text,1)), LOWER(RIGHT(d.sport::text,LENGTH(d.sport::text)-1))),' ', 'Drop-in') END AS title
      FROM (SELECT * FROM event_sign_up WHERE client_id = ${req.query.typeSpecificId}) AS esu 
      LEFT JOIN event e ON esu.event_id = e.event_id 
      LEFT JOIN program p ON e.event_id = p.event_id
      LEFT JOIN drop_in d ON d.event_id = e.event_id`

  try {
    const promiseArr = [
      db.client.query(`
        SELECT 
          a.title,
          a.message AS content,
          a.created_at AS date,
          CONCAT(ac.first_name, ' ', ac.last_name) AS subtitle,
          p.program_name,
          d.sport,
          e.event_type
        FROM 
          (SELECT * FROM announcement ORDER BY created_at DESC LIMIT 1) 
        AS a 
        LEFT JOIN employee emp ON emp.employee_id = a.created_by
        LEFT JOIN account ac ON ac.username = emp.username
        LEFT JOIN event_announcement ea ON a.announcement_id = ea.announcement_id 
        LEFT JOIN event e ON e.event_id = ea.event_id 
        LEFT JOIN program p ON p.event_id = e.event_id 
        LEFT JOIN drop_in d ON d.event_id = e.event_id
      `),
      db.client.query('SELECT * FROM (SELECT * FROM announcement ORDER BY created_at DESC LIMIT 1) AS a LEFT JOIN facility_announcement fa ON a.announcement_id = fa.announcement_id'),
      db.client.query(`
        SELECT
          bp.created_at AS date,
          bp.title,
          bp.content,
          CONCAT(a.first_name, ' ', a.last_name) AS subtitle 
        FROM (
          SELECT * 
          FROM bulletin_post 
          WHERE is_public = true 
          ORDER BY created_at DESC 
          LIMIT 3) 
        AS bp 
        LEFT JOIN client c 
        ON bp.created_by = c.client_id 
        LEFT JOIN account a
        ON a.username = c.username`
      ),
      db.client.query(eventQuery)
    ]

    const [eventAnnouncement, facilityAnnouncement, bulletinPosts, events] = await Promise.all(promiseArr)

    const tags = []
    facilityAnnouncement.rows.forEach((item) => { if (item.facility_name) tags.push(item.facility_name) })
    eventAnnouncement.rows.forEach((item) => {
      if (item.event_type) {
        tags.push(item.event_type === 'drop-in'
          ? `${item.sport.charAt(0).toUpperCase() + item.sport.slice(1)} Drop-in`
          : item.program_name)
      }
    })

    res.status(200).json({
      announcement: { ...eventAnnouncement.rows[0], tags },
      bulletinPosts: bulletinPosts.rows,
      events: events.rows,
    })

  } catch (err) {
    res.status(500).json(err)
  }
}

export default {
  getDashboard,
}