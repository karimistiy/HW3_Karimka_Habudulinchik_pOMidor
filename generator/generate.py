import csv
import random
import os
import sys
NUM_ROWS = 50
COLUMNS = ["DISH_NAME", "PRICE", "WEIGHT_G", "CATEGORY"]
def generate_row():
    return {
        "DISH_NAME": random.choice(["Эчпочмак", "Перемяч", "Чак-чак", "Азу по-татарски", "Шурпа", "Айран"]),
        "PRICE": round(random.uniform(80, 800), 2),
        "WEIGHT_G": random.randint(100, 500),
        "CATEGORY": random.choice(["Выпечка", "Десерт", "Горячее", "Суп", "Напиток"]),
    }
OUTPUT_DIR = sys.argv[1] if len(sys.argv) > 1 else "/data"
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "data.csv")
os.makedirs(OUTPUT_DIR, exist_ok=True)
rows = [generate_row() for _ in range(NUM_ROWS)]
with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=COLUMNS)
    writer.writeheader()
    writer.writerows(rows)
