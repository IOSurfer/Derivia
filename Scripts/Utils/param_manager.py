import json
from pathlib import Path

class ParamManager:
    def __init__(self, persist_file: Path):
        self.persist_file = persist_file
        self.params = {}

    def load(self):
        if not self.persist_file.exists():
            raise FileNotFoundError(f"Persistence file not found: {self.persist_file}")
        with open(self.persist_file, "r", encoding="utf-8") as f:
            self.params = json.load(f)
        print(f"[ParamManager] Loaded parameters from {self.persist_file}")
        return self.params

    def save(self, params: dict):
        self.params = params
        with open(self.persist_file, "w", encoding="utf-8") as f:
            json.dump(self.params, f, indent=2)
        print(f"[ParamManager] Saved parameters to {self.persist_file}")

    def get(self, key, default=None):
        return self.params.get(key, default)

    def update(self, new_params: dict):
        self.params.update(new_params)