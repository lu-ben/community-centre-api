import db from '../../config/db.js'
import { ERROR } from '../../utils/enum.js'

const getBulletin = async (req, res) => {
  if (!req.query.accountType || !req.query.typeSpecificId) {
    res.status(400).json({ error: { message: ERROR.TID_NF } })
    return
  }

  let approvedOnly = ''
  if (req.query.accountType === 'client') approvedOnly = 'WHERE b.is_public = true'

  try {
    const bulletin = await db.client.query(`
      SELECT
        b.post_id as id,
        b.created_at as date,
        b.title,
        b.content,
        b.is_public as disabled,
        CONCAT(ac.first_name, ' ', ac.last_name) AS subtitle
      FROM bulletin_post as b
      LEFT JOIN client c ON c.client_id = b.created_by
      LEFT JOIN account ac ON ac.username = c.username
      ${approvedOnly}
      ORDER BY b.created_at DESC
    `);

    res.status(200).json({
      bulletin: bulletin.rows,
    })

  } catch (err) {
    console.log(err)
    res.status(500).json(err)
  }
}

const createBulletin = async (req, res) => {
  try {
    const {
      title,
      content,
    } = req.query

    if (title && content && req.query.typeSpecificId) {
      const result = await db.client.query(`INSERT INTO bulletin_post (title, content, created_by) VALUES ('${title}', '${content}', ${Number(req.query.typeSpecificId)}) RETURNING *`);
      res.status(200).json({ bulletin: result.rows[0]});
    } else {
      res.status(500).json({ error: { message: ERROR.RFE } })
    }
  } catch (err) {
    console.log(err)
    res.status(500).json(err)
  }
}

const approveBulletin = async(req, res) => {
  try {
    if (req.query.typeSpecificId && req.query.postId) {
      const result = await db.client.query(`UPDATE bulletin_post SET is_public = true, approved_by = ${Number(req.query.typeSpecificId)} WHERE post_id = ${Number(req.query.postId)} RETURNING *`);
      res.status(200).json({ bulletin: result.rows[0]})
    }
  } catch(err) {
    console.log(err)
    res.status(500).json(err)
  }
}

const deleteBulletin = async(req, res) => {
  try {
    if (req.query.postId) {
      const result = await db.client.query(`DELETE FROM bulletin_post WHERE post_id = ${Number(req.query.postId)} RETURNING *`);
      res.status(200).json({ bulletin: result.rows[0]})
    }
  } catch(err) {
    console.log(err)
    res.status(500).json(err)
  }
}

export default {
  getBulletin,
  createBulletin,
  approveBulletin,
  deleteBulletin,
}
