import db from '../../config/db.js'
import { ERROR } from '../../utils/enum.js'

const login = async (req, res) => {
  try {
    if (Object.keys(req.query).length < 1 || req.query.username === undefined) {
      res.status(400).json({ error: { message: ERROR.UID_NF } })
    }

    const account = await db.client.query(`SELECT * FROM account WHERE username='${req.query.username}'`)

    if (Number(req.query.pin) === account.rows[0].pin) {
      res.status(200).json({
        username: account.rows[0].username,
        first_name: account.rows[0].first_name,
        user_type: account.rows[0].user_type
      })
    } else {
      res.status(500).json({ error: { message: 'Username or Pin incorrect!' } })
    }
  } catch (err) {
    res.status(500).json(err)
  }
}

export default {
  login,
}