import db from '../../config/db.js'
import { ERROR } from '../../utils/enum.js'

const login = async (req, res) => {
  try {
    if (Object.keys(req.query).length < 1 || req.query.username === undefined) {
      res.status(400).json({ error: { message: ERROR.UN_NF } })
    }

    const account = await db.client.query(`SELECT * FROM account WHERE username='${req.query.username}'`)

    if (Number(req.query.pin) === Number(account.rows[0].pin)) {
      const accountSubtype = await db.client.query(`SELECT * FROM ${account.rows[0].account_type} WHERE username='${req.query.username}'`);
      res.status(200).json({
        username: account.rows[0].username,
        firstName: account.rows[0].first_name,
        accountType: account.rows[0].account_type,
        typeSpecificId: account.rows[0].account_type === 'employee' ? accountSubtype.rows[0].employee_id : accountSubtype.rows[0].client_id,
      })
    } else {
      res.status(500).json({ error: { message: ERROR.IC } })
    }
  } catch (err) {
    res.status(500).json(err)
  }
}

const signup = async (req, res) => {
  try {

    const {
      username,
      firstName,
      lastName,
      pin,
      accountType,
      employeeRole,
    } = req.query

    if (username && firstName && pin && accountType) {
      await db.client.query(`INSERT INTO account VALUES ('${username}', '${firstName}', '${lastName}', ${pin}, '${accountType}')`);
      if (accountType === 'employee') {
        await db.client.query(`INSERT INTO employee (role, username) VALUES ('${employeeRole}', '${username}')`)
        res.status(200).json({})
      }
      if (accountType === 'client') {
        await db.client.query(`INSERT INTO client (age, username) VALUES (${Number(req.query.age)}, '${username}')`)
        res.status(200).json({})
      }
    } else {
      res.status(500).json({ error: { message: ERROR.RFE } })
    }
  } catch (err) {
    res.status(500).json(err)
  }
}

export default {
  login,
  signup,
}