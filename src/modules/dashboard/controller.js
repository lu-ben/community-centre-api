import db from '../../config/db.js'
import { ERROR } from '../../utils/enum.js'

const getDashboard = async (req, res) => {

  if (!req.query.accountType || !req.query.typeSpecificId) {
    res.status(400).json({ error: { message: ERROR.TID_NF } })
    return
  }

  const eventQuery = req.query.accountType === 'employee'
    ? `SELECT * FROM event e LEFT JOIN ON program p ON e.event_id = p.event_id WHERE instructed_by = ${Number(req.query.typeSpecificId)}`
    : `SELECT * FROM event_sign_up es LEFT JOIN event e ON es.event_id = e.event_id WHERE es.client_id = ${Number(req.query.typeSpecificId)}`

  try {
    const promiseArr = [
      db.client.query(`
      SELECT 
        a.title, a.message, a.announcement_id, a.created_by, a.created_at, ac.first_name, ac.last_name, p.program_name, d.sport, e.event_type 
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
      // TODO: update below two queries to have the correct field names and data
      db.client.query('SELECT * FROM bulletin_post WHERE is_public = true ORDER BY created_at DESC LIMIT 3'),
      db.client.query(eventQuery)
    ]

    const [eventAnnouncement, facilityAnnouncement, bulletinPosts, events] = await Promise.all(promiseArr)

    const tags = []
    eventAnnouncement.rows.forEach((item) => tags.push(item.event_type === 'drop-in' ? `${item.sport.charAt(0).toUpperCase() + item.sport.slice(1)} Drop-in` : item.program_name))
    facilityAnnouncement.rows.forEach((item) => tags.push(item.facility_name))

    const latestAnnouncement = {
      title: eventAnnouncement.rows[0].title,
      subtitle: `${eventAnnouncement.rows[0].first_name} ${eventAnnouncement.rows[0].last_name}`,
      content: eventAnnouncement.rows[0].message,
      date: eventAnnouncement.rows[0].created_at,
      tags,
    }

    res.status(200).json({
      announcement: latestAnnouncement,
      bulletinPosts: bulletinPosts.rows,
      events: events.rows,
    })

  } catch (err) {
    console.log(err)
    res.status(500).json(err)
  }
}

export default {
  getDashboard,
}