import json
import os

import boto3
import pymysql
from flask import Flask, render_template

app = Flask(__name__)


def get_db_secret():
    secret_name = os.environ["SECRET_NAME"]
    region_name = os.environ.get("AWS_REGION", "us-east-2")

    client = boto3.client("secretsmanager", region_name=region_name)
    response = client.get_secret_value(SecretId=secret_name)

    return json.loads(response["SecretString"])


def get_inventory():
    secret = get_db_secret()

    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["database"],
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
