#!/usr/bin/env python3

import torch
from torch import nn
import re


class ScoreModel(nn.Module):
    def __init__(
        self,
        input_dim,
        logistic_dim1,
        logistic_dim2,
        logistic_dim3,
        score_dim1,
        score_dim2,
    ):
        super(ScoreModel, self).__init__()
        self.logisticMode = True
        self.useInputDropout = False

        self.log1 = nn.Sequential(
            nn.Linear(input_dim, logistic_dim1),
            nn.Sigmoid(),
            nn.Dropout(0.5),
            nn.Linear(logistic_dim1, logistic_dim2),
            nn.Sigmoid(),
            nn.Dropout(0.5),
            nn.Linear(logistic_dim2, logistic_dim3),
            nn.Sigmoid(),
            nn.Dropout(0.5),
            nn.Linear(logistic_dim3, logistic_dim3),
            nn.Sigmoid(),
            nn.Dropout(0.5),
            nn.Linear(logistic_dim3, logistic_dim3),
            nn.Sigmoid(),
        )

        self.log2 = nn.Sequential(
            nn.Linear(input_dim, logistic_dim1),
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(logistic_dim1, logistic_dim2),
            nn.Sigmoid(),
            nn.Dropout(0.5),
            nn.Linear(logistic_dim2, logistic_dim3),
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(logistic_dim3, logistic_dim3),
            nn.Sigmoid(),
            nn.Dropout(0.5),
            nn.Linear(logistic_dim3, logistic_dim3),
            nn.ReLU(),
        )

        self.log3 = nn.Sequential(
            nn.Linear(input_dim, logistic_dim1),
            nn.Tanh(),
            nn.Dropout(0.5),
            nn.Linear(logistic_dim1, logistic_dim2),
            nn.Tanh(),
            nn.Dropout(0.5),
            nn.Linear(logistic_dim2, logistic_dim3),
            nn.Tanh(),
            nn.Dropout(0.5),
            nn.Linear(logistic_dim3, logistic_dim3),
            nn.Tanh(),
            nn.Dropout(0.5),
            nn.Linear(logistic_dim3, logistic_dim3),
            nn.Tanh(),
        )
        self.logout = nn.Linear(logistic_dim3 * 3, 1)

        self.input_drop = nn.Dropout(0.1)
        self.logistic_drop = nn.Dropout(0.5)
        self.score_drop = nn.Dropout(0.0)

        self.relu = nn.ReLU()

        self.loglin1 = nn.Linear(input_dim, logistic_dim1)
        self.loglin2 = nn.Linear(logistic_dim1, logistic_dim2)
        self.loglin3 = nn.Linear(logistic_dim2, logistic_dim3)

        self.logpredict = nn.Linear(logistic_dim3, 1)

        self.scorelin1 = nn.Linear(input_dim + logistic_dim3, score_dim1)
        self.scorelin2 = nn.Linear(score_dim1, score_dim2)

        self.scorepredict = nn.Linear(score_dim2, 1)

        self.scoreNetwork = [self.scorelin1, self.scorelin2, self.scorepredict]

        # self.SetLogisticMode(self.logisticMode)

    def SetLogisticMode(self, mode):
        self.logisticMode = mode
        if self.logisticMode:
            for param in self.logpredict.parameters():
                param.requires_grad = True

            for layer in self.scoreNetwork:
                for param in layer.parameters():
                    param.requires_grad = False

        else:
            for param in self.logpredict.parameters():
                param.requires_grad = False

            for param in layer.parameters():
                param.requires_grad = True

    def forward(self, x):

        x1 = self.log1(x)
        x2 = self.log2(x)
        x3 = self.log3(x)

        Lx = torch.cat([x1, x2, x3], dim=-1)
        return torch.sigmoid(self.logout(Lx))


def main(args):
    if len(args) != 2:
        print("Expects 2 arguments. Usage: python3 dock2bind.py <model> <scores>")
        exit(1)

    model_file = args[0]
    dock_file = args[1]

    model = ScoreModel(20, 128, 256, 512, 256, 512)
    model.load_state_dict(torch.load(model_file))
    model.requires_grad_(False)

    names = []
    vals = []

    sample_num = 20

    with open(dock_file) as file:
        for i, line in enumerate(file):
            if i == 0:  # we expect the header
                continue

            line = line.strip()
            cols = re.split(r"[ \t,]+", line)

            if len(cols) != 19:
                continue

            v = [0.0, 0.0, 0.0]

            for j, value in enumerate(cols[1:]):
                try:
                    v.append(float(value))
                except:
                    print(f"value at index {j + 2} ({value}) must be a float")
                    exit(2)

            names.append(cols[:1])
            vals.append(v)

    data = torch.tensor(vals)
    out = model(data).squeeze()
    for i in range(sample_num - 1):
        out += model(data).squeeze()
    data = out

    for i in range(len(data)):
        score = float(data[i]) / float(sample_num)
        print(f"{names[i][0]}\t{score:.4}")


if __name__ == "__main__":
    import sys

    main(sys.argv[1:])
