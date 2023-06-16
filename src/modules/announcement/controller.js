import db from '../../config/db.js'
import { ERROR } from '../../utils/enum.js'

const getAnnouncement = async (req, res) => {
  if (!req.query.accountType || !req.query.typeSpecificId) {
    res.status(400).json({ error: { message: ERROR.TID_NF } })
    return
  }

  try {
    const announcements = await db.client.query(`
      (SELECT
        a.announcement_id,
        a.title,
        a.message AS content,
        a.created_at AS date,
        CONCAT(ac.first_name, ' ', ac.last_name) AS subtitle,
        CASE
          WHEN e.event_type = 'drop-in' THEN CONCAT(CONCAT(UPPER(LEFT(d.sport::text,1)), LOWER(RIGHT(d.sport::text,LENGTH(d.sport::text)-1))),' ', 'Drop-in')
          WHEN e.event_type = 'program' then p.program_name
          END AS tag_name
      FROM announcement a
      LEFT JOIN employee emp ON emp.employee_id = a.created_by
      LEFT JOIN account ac ON ac.username = emp.username
      LEFT JOIN event_announcement ea ON a.announcement_id = ea.announcement_id
      LEFT JOIN event e ON e.event_id = ea.event_id
      LEFT JOIN program p ON p.event_id = e.event_id
      LEFT JOIN drop_in d ON d.event_id = e.event_id)
      UNION ALL
      (SELECT
        a2.announcement_id,
        a2.title,
        a2.message AS content,
        a2.created_at AS date,
        CONCAT(ac2.first_name, ' ', ac2.last_name) AS subtitle,
        fa.facility_name AS tag_name
      FROM announcement a2
      LEFT JOIN facility_announcement fa ON a2.announcement_id = fa.announcement_id
      LEFT JOIN employee emp2 ON emp2.employee_id = a2.created_by
      LEFT JOIN account ac2 ON ac2.username = emp2.username)
      ORDER BY date ASC
    `)

    const result = {}
    announcements.rows.forEach((item) => {
      if (result[item.announcement_id] !== undefined) {
        if (item.tag_name) result[item.announcement_id].tags.push(item.tag_name)
      } else {
        let tags = []
        if (item.tag_name) tags.push(item.tag_name)
        result[item.announcement_id] = {
          title: item.title,
          content: item.content,
          date: item.date,
          subtitle: item.subtitle,
          tags,
        }
      }
    })

    res.status(200).json({
      announcement: Object.values(result),
    })

  } catch (err) {
    console.log(err)
    res.status(500).json(err)
  }
}

const getAnnouncementOptions = async (req, res) => {
  if (req.query.accountType === 'employee') {
    try {
      const promiseArr = [
        db.client.query('SELECT facility_name FROM facility'),
        db.client.query(`
          SELECT
            e.event_id,
            CASE WHEN e.event_type = 'program' THEN p.program_name
            ELSE CONCAT(CONCAT(UPPER(LEFT(d.sport::text,1)), LOWER(RIGHT(d.sport::text,LENGTH(d.sport::text)-1))),' ', 'Drop-in') END AS title
          FROM event e
          LEFT JOIN program p ON e.event_id = p.event_id
          LEFT JOIN drop_in d ON d.event_id = e.event_id
        `),
      ]

      const [facilityOptions, eventOptions] = await Promise.all(promiseArr)

      res.status(200).json({
        facilityOptions: facilityOptions.rows,
        eventOptions: eventOptions.rows,
      })

    } catch (err) {
      console.log(err)
      res.status(500).json(err)
    }
  }
}

const createAnnouncement = async (req, res) => {
  try {
    const {
      title,
      content,
      facilityNames,
      eventIds,
    } = req.query

    if (title && content && req.query.typeSpecificId) {
      const result = await db.client.query(`INSERT INTO announcement (title, message, created_by) VALUES ('${title}', '${content}', ${Number(req.query.typeSpecificId)}) RETURNING *`);
      const announcementId = result.rows[0].announcement_id;

      if (facilityNames !== undefined) {
        for (const facility of facilityNames) {
          await db.client.query(`INSERT INTO facility_announcement VALUES (${announcementId}, '${facility}')`)
        }
      }
      if (eventIds !== undefined) {
        for (const event of eventIds) {
          await db.client.query(`INSERT INTO event_announcement VALUES (${announcementId}, ${event})`)
        }
      }
      res.status(200).json({});
    } else {
      res.status(500).json({ error: { message: ERROR.RFE } })
    }
  } catch (err) {
    console.log(err)
    res.status(500).json(err)
  }
}

export default {
  getAnnouncement,
  getAnnouncementOptions,
  createAnnouncement,
}
