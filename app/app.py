import os
import pymysql
from flask import Flask, render_template

app = Flask(__name__)

def get_inventory():
    connection = pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        database=os.environ["DB_NAME"],
        cursorclass=pymysql.cursors.DictCursor
    )

    with connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id, item, category, quantity FROM inventory;")
            return cursor.fetchall()

@app.route("/")
def home():
    inventory = get_inventory()
    return render_template("index.html", inventory=inventory)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
