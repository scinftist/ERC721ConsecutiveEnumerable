from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import accounts, config, network, ERC721ETest, FT
from time import sleep
import numpy as np
import random
import sys


def deploy_and_create(tokens, accs, runs, mint_req=True):
    account = get_account()
    # num_tokens = 1 + tokens
    # num_tokens = 10
    zeroAdd = "0x0000000000000000000000000000000000000000"
    num_acc = accs
    run = runs
    # run = 20
    # num_tokens = 50
    print(account)
    demo = FT.deploy({"from": account})
    testo = ERC721ETest.deploy({"from": account})
    # demo = testo
    for i in range(10):

        testo.mint(100, {"from": account})
    # testo.mint(num_tokens, {"from": account})
    # testo.mint(num_tokens, {"from": account})
    # testo.mint(num_tokens, {"from": account})
    # testo.mint(num_tokens, {"from": account})
    # demo.safeTransferFrom(
    #     accounts[0],
    #     accounts[1],
    #     0,
    #     {"from": accounts[0], "silent": True},
    # )

    # testo.safeTransferFrom(
    #     accounts[0],
    #     accounts[1],
    #     0,
    #     {"from": accounts[0], "silent": True},
    # )

    print("test is:", (testo.totalSupply() == demo.totalSupply()))
    print(demo.totalSupply())
    print(testo.totalSupply())

    def trans():

        cas = random.randint(0, 100)

        if cas < 90:
            sup = demo.totalSupply()
            rndTok = demo.tokenByIndex(random.randint(0, sup - 1))
            own = demo.ownerOf(rndTok)
            otheracc = own
            while own == otheracc:
                otheracc = accounts[random.randint(0, num_acc - 1)]
            # print(otheracc, own, rndTok)
            # sleep(3)
            print("transfering", rndTok)
            demo.safeTransferFrom(
                own,
                otheracc,
                rndTok,
                {"from": own, "silent": True},
            )
            sleep(0.05)
            testo.safeTransferFrom(
                own,
                otheracc,
                rndTok,
                {"from": own, "silent": True},
            )
        else:
            someacc = accounts[random.randint(0, num_acc - 1)]
            flag = True
            while flag:
                print("minting ..")
                try:
                    _t = random.randint(0, 5000)
                    ownerTemp = demo.ownerOf(_t)
                except:
                    flag = False

            demo.singleMintArbi(_t, {"from": someacc})
            testo.singleMintArbi(_t, {"from": someacc})
            # demo.singleMint({"from": someacc})
            # testo.singleMint({"from": someacc})

    def eval():
        total = 0
        ev = 0
        for i in range(num_acc):
            total += 1
            bal = demo.balanceOf(accounts[i])
            balt = testo.balanceOf(accounts[i])
            try:
                assert bal == balt
                ev += 1
            except:
                print("balances of ", i, "is", bal, balt)
            for j in range(bal):
                total += 1
                tok = demo.tokenOfOwnerByIndex(accounts[i], j)
                tokt = testo.tokenOfOwnerByIndex(accounts[i], j)
                try:
                    assert tok == tokt
                    ev += 1
                except:
                    print("skrew", i, j, tok, tokt)
                    Fi = open(
                        "./reports/reportTX.txt",
                        "a",
                    )
                    Fi.write(
                        ("index_output_check exept in i = " + str(i) + " j= " + str(j))
                    )
                    # Close the file
                    Fi.close()

        print("evaluation: ", ev, "/", total)
        Fi = open("./reports/reportTX.txt", "a")
        Fi.write(("\n evaluation: " + str(ev) + "/" + str(total) + "\n"))
        # Close the file
        Fi.close()
        if ev == total:
            return True
        else:
            return False

    for i in range(1 + run // 2):
        # print(i, flush=True)
        trans()
        sys.stdout.write(str(i))
        sys.stdout.flush()
    # demo.singleMint({"from": accounts[2]})
    # testo.singleMint({"from": accounts[2]})
    # demo.singleMint({"from": accounts[2]})
    # testo.singleMint({"from": accounts[2]})
    # demo.singleMint({"from": accounts[1]})
    # testo.singleMint({"from": accounts[1]})
    # demo.singleMint({"from": accounts[0]})
    # testo.singleMint({"from": accounts[0]})
    for i in range(1 + run // 2):
        # print(i, flush=True)
        trans()
        sys.stdout.write(str(i))
        sys.stdout.flush()
    # def testingRun(300):
    # for i
    print("phase1")
    sleep(3)
    eval()

    def printList(add):
        print("list of acc:", add)
        bal = demo.balanceOf(add)
        for i in range(bal):
            print("index ", i, " is token", demo.tokenOfOwnerByIndex(add, i))

    # def pl4():
    #     printList(account)
    #     printList(accounts[1])
    #     printList(accounts[2])
    #     printList(accounts[3])
    # def index_output():
    #     for i in range(num_acc):
    #         bal = demo.balanceOf(accounts[i])
    #         for j in range(bal):
    #             print(
    #                 "acc:",
    #                 i,
    #                 " index ",
    #                 j,
    #                 " is token",
    #                 demo.tokenOfOwnerByIndex(accounts[i], j),
    #                 testo.tokenOfOwnerByIndex(accounts[i], j),
    #             )
    def index_output_check():
        Fi = open("./reports/reportTX.txt", "a")
        total = 0
        ev = 0
        nt = 0
        for i in range(num_acc):

            bal = demo.balanceOf(accounts[i])
            for j in range(bal):
                total += 1
                try:

                    assert demo.tokenOfOwnerByIndex(
                        accounts[i], j
                    ) == testo.tokenOfOwnerByIndex(accounts[i], j)
                    ev += 1
                    Fi.write(
                        (
                            " token index "
                            + str(nt)
                            + ": belong to acc "
                            + str(i)
                            + " : index"
                            + str(j)
                            + ":"
                            + str(demo.tokenOfOwnerByIndex(accounts[i], j))
                            + " = "
                            + str(testo.tokenOfOwnerByIndex(accounts[i], j))
                            + "\n"
                        )
                    )
                    nt += 1
                except:
                    print("index_output_check exept in i = ", i, " j= ", j)

        print("evaluation: ", ev, "/", total)
        # Fi = open("./reports/reportTX.txt", "a")
        Fi.write((" index-check \n evaluation: " + str(ev) + "/" + str(total) + "\n"))
        # Close the file
        Fi.close()

    # def index_check():
    #     for i in range(num_acc):
    #         bal = demo.balanceOf(accounts[i])
    #         for j in range(bal):
    #             # print(
    #             #     "acc:",
    #             #     i,
    #             #     " index ",
    #             #     j,
    #             #     " is token",
    #             #     demo.tokenOfOwnerByIndex(accounts[i], j),
    #             #     testo.tokenOfOwnerByIndex(accounts[i], j),
    #             # )

    #             assert demo.tokenOfOwnerByIndex(
    #                 accounts[i], j
    #             ) == testo.tokenOfOwnerByIndex(accounts[i], j)
    # eval
    print("eval")
    eval()
    print("index-check")
    sleep(2)
    # index_output()
    index_output_check()
    # index_check()
    sleep(3)
    # pl4()
    # # demo.safeTransferFrom(account, accounts[1], 7, {"from": account})
    # # demo.safeTransferFrom(account, accounts[1], 1, {"from": account})
    # # demo.safeTransferFrom(accounts[1], account, 7, {"from": accounts[1]})
    # # demo.safeTransferFrom(accounts[1], account, 1, {"from": accounts[1]})
    # # pl4()
    # demo.safeTransferFrom(account, accounts[1], 0, {"from": account})
    # demo.safeTransferFrom(account, accounts[1], 10, {"from": account})
    # demo.safeTransferFrom(accounts[1], account, 10, {"from": accounts[1]})
    # demo.safeTransferFrom(account, accounts[2], 10, {"from": account})
    # demo.safeTransferFrom(account, accounts[1], 1, {"from": account})
    # demo.safeTransferFrom(accounts[1], account, 0, {"from": accounts[1]})
    # demo.safeTransferFrom(account, accounts[1], 0, {"from": account})
    # demo.safeTransferFrom(account, accounts[1], 2, {"from": account})
    # demo.safeTransferFrom(accounts[1], account, 1, {"from": accounts[1]})
    # # demo.safeTransferFrom(account, accounts[1], 10, {"from": account})
    # pl4()

    return demo


# luv you dude <3


def main():
    for i in range(10):
        r = random.randint(0, 1)  # tokens
        g = random.randint(7, 8)  # acc
        b = random.randint(50, 200)  # runs
        Fi = open("./reports/reportTX.txt", "a")
        Fi.write("\ntest no: " + str(i) + " runs: " + str(b) + " accs:" + str(g) + "\n")
        # Close the file
        Fi.close()

        # r = random.randint(0, 1)  # tokens
        # g = random.randint(2, 8)  # acc
        # b = random.randint(10, 50)  # runs
        print(" tokens: ", r + 1, " acc: ", g, " runs: ", b)
        deploy_and_create(r, g, b, True)
