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
    console.log(err)
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
    console.log(err)
    res.status(500).json(err)
  }
}

const accounts = async (req, res) => {
  const {
    accountTypeSelected: accountType,
    ageSelected: age,
    roleSelected: role,
  } = req.query

  const alias = accountType === 'Client' ? 'c' : 'e'
  const table = accountType === 'Client' ? `client_with_age_ranges ${alias}` : `employee ${alias}`
  const projection = accountType === 'Client' ? 'c.client_id AS title, c.age_range, c.age' : 'e.employee_id AS title, e.role'
  const sort = accountType === 'Client' ? 'c.client_id' : 'e.employee_id'

  let filters = ''
  if (accountType === 'Employee' && role && role !== 'All') filters = `WHERE e.role = '${role.toLowerCase()}'`
  if (accountType === 'Client' && age && age !== 'All') filters = `WHERE c.age_range = '${age.toLowerCase()}'`

  try {
    const accounts = await db.client.query(`
      SELECT a.username, a.first_name, a.last_name, a.account_type, ${projection}
      FROM ${table}
      LEFT JOIN account a ON ${alias}.username = a.username
      ${filters}
      ORDER BY ${sort}
    `)
    res.status(200).json({ accounts: accounts.rows })
  } catch (err) {
    console.log(err)
    res.status(500).json(err)
  }
}

const updateUser = async (req, res) => {
  try {
    const {
      title,
      first_name,
      last_name,
      username,
      age,
      account_type,
    } = req.query

    if (title && first_name && last_name && username) {
      if (account_type === 'client') {
        await db.client.query(`UPDATE client SET age = ${Number(age)} WHERE client_id = ${Number(title)}`);
      }
      if (account_type === 'employee') {
        await db.client.query(`UPDATE employee SET role = '${req.query.role}' WHERE employee_id = ${Number(title)}`);
      }
      await db.client.query(`UPDATE account SET first_name = '${first_name}', last_name = '${last_name}' WHERE username = '${username}'`);
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
  login,
  signup,
  accounts,
  updateUser,
}
