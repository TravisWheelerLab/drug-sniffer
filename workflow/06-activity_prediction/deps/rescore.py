#!/usr/bin/env python3

import torch
from torch import nn
import re
import sys


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

        if self.useInputDropout:
            x = self.input_drop(x)

        Lx = self.logistic_drop(self.relu(self.loglin1(x)))

        Lx = self.logistic_drop(self.relu(self.loglin2(Lx)))
        Lx = self.logistic_drop(self.relu(self.loglin3(Lx)))

        if self.logisticMode:
            return torch.sigmoid(self.logpredict(Lx))

        #  x = x.unsqueeze(-1)
        # print(x.shape, Lx.shape)
        x = torch.cat((x, Lx), dim=-1)

        x = self.score_drop(self.sigmoid(self.scorelin1(x)))
        x = self.score_drop(self.relu(self.scorelin2(x)))

        return self.scorepredict(x)


if len(sys.argv) != 3:
    print("Expects 2 arguments. Usage: python3 score.py model.h5 score_file.score")
    exit(-1)

model_file = sys.argv[1]
dock_file = sys.argv[2]

model = ScoreModel(20, 128, 256, 512, 256, 512)
model.load_state_dict(torch.load(model_file))

model.requires_grad_(False)


names = []
vals = []

sample_num = 20


with open(dock_file) as file:
    lines = file.readlines()
    for i, line in enumerate(lines):
        if i == 0:  # we expect the header
            continue
        line.replace("\n", "")
        line.replace("\\n", "")
        cols = re.split(r"[ \t,]+", line)
        # print(cols)
        # cols.replace('\n', '')

        if len(cols) != 19:
            continue

        v = []
        v.append(0.0)
        v.append(0.0)
        v.append(0.0)

        for j in cols[2:]:
            try:
                v.append(float(j))
            except:
                print(j)

        name = cols[0:2]

        name.append(dock_file)
        names.append(name)
        vals.append(v)


data = torch.tensor(vals)
# print(len(vals), len(names), data.shape)
out = model(data).squeeze()
for i in range(sample_num - 1):
    out += model(data).squeeze()
data = out


for i in range(len(data)):
    print(names[i][0], names[i][1], names[i][2], float(data[i]) / float(sample_num))
