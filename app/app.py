from flask import Flask, render_template

app = Flask(__name__)

inventory = [
    {
        "id": 1,
        "item": "Laptop",
        "category": "IT Equipment",
        "quantity": 25
    },
    {
        "id": 2,
        "item": "Monitor",
        "category": "IT Equipment",
        "quantity": 40
    },
    {
        "id": 3,
        "item": "Office Chair",
        "category": "Furniture",
        "quantity": 15
    }
]

@app.route("/")
def home():
    return render_template("index.html", inventory=inventory)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
