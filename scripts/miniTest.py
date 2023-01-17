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
    # listMint = [0, 1, 2, 3, 4]
    minted = [i for i in range(150)]
    print(minted)
    burned = [i + 150 for i in range(150)]
    print(burned)
    # print("list:", listMint)
    # listMint.pop(2)
    # print("list:", listMint)
    # listMint.pop(2)

    # print("list:", listMint)
    # num_tokens = 10

    verbose = True

    zeroAdd = "0x0000000000000000000000000000000000000000"
    num_acc = accs
    run = runs
    # run = 20
    # num_tokens = 50
    sleep(0.05)
    print(account)
    demo = FT.deploy([accounts[0], accounts[1], accounts[2]], {"from": account})
    testo = ERC721ETest.deploy({"from": account})
    # demo = testo
    # for i in range(10):
    sleep(0.05)
    testo.mint(50, {"from": accounts[0]})
    # for i in range(10):
    sleep(0.05)
    testo.mint(50, {"from": accounts[1]})
    # for i in range(10):
    sleep(0.05)
    testo.mint(50, {"from": accounts[2]})

    print("test is:", (testo.totalSupply() == demo.totalSupply()))
    sleep(0.05)
    print(demo.totalSupply())
    sleep(0.05)
    print(testo.totalSupply())
    sleep(0.05)
    add_dict = {}
    for i in range(num_acc):
        add_dict[str(accounts[i])] = "acc-" + str(i)

    def ad(_ac):
        return add_dict[_ac]

    def tellME(_data):
        Fi = open(
            "./reports/report_Info.txt",
            "a",
        )
        if verbose:
            Fi.write(_data)
        # Close the file
        Fi.close()

    def tokenByInd():
        verbose = True
        tellME("check\n")

        try:
            sleep(0.05)
            supd = demo.totalSupply()
            sleep(0.05)
            supt = testo.totalSupply()
            assert supd == supt

        except:
            tellME("ERR: supply " + ad(str(supd)) + "  " + ad(str(supt)))
            raise (KeyboardInterrupt)
        tellME("supply " + str(supd) + "  " + str(supt) + "\n")
        for i in range(supd):
            sleep(0.05)
            a = demo.tokenByIndex(i)
            try:
                sleep(0.05)
                a1 = ad(str(demo.ownerOf(a)))
            except:
                tellME(
                    "ERR tokenByIndex"
                    + " -index:"
                    + str(i)
                    + " tokenId: "
                    + str(a)
                    + " sup "
                    + str(supd)
                    + "-"
                    + str(supt)
                    + "\n"
                )
                try:
                    index_output_check()
                except:
                    tellME("ERR did'not")
                raise (KeyboardInterrupt)

            b = testo.tokenByIndex(i)
            b1 = ad(str(demo.ownerOf(b)))

            tellME(
                "index: "
                + str(i)
                + " tokenID: "
                + a1
                + " "
                + str(a)
                + " "
                + b1
                + " "
                + str(b)
                + "\n"
            )

    def trans():

        cas = random.randint(0, 100)

        if cas < 50:
            try:
                tellME("t\n")
                sup = demo.totalSupply()
                sleep(0.05)
                rndTok = demo.tokenByIndex(random.randint(0, sup - 1))
                sleep(0.05)
                own = demo.ownerOf(rndTok)
                sleep(0.05)
                otheracc = own

                while own == otheracc:
                    otheracc = accounts[random.randint(0, num_acc - 1)]
                # print(otheracc, own, rndTok)
                # sleep(3)
                print(type(own))
                tellME(
                    "transfer : "
                    + str(rndTok)
                    + " from: "
                    + ad(str(own))
                    + " to : "
                    + ad(str(otheracc))
                    + "\n"
                )
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
                sleep(0.05)
            except:
                # verbose = True
                tellME(("ERR ...............t1\n") * 5)
                index_output_check()
                raise (KeyboardInterrupt)
            # tokenByInd()
        else:
            cas1 = random.randint(0, 100)

            if cas1 < 50:
                try:
                    tellME("m\n")
                    someacc = accounts[random.randint(0, num_acc - 1)]
                    flag = True
                    # while flag:
                    #     print("minting ..")
                    #     try:
                    #         _t = random.randint(0, 500)
                    #         ownerTemp = demo.ownerOf(_t)
                    #     except:
                    #         flag = False
                    _t = burned.pop(random.randint(0, len(burned) - 1))
                    minted.append(_t)
                    tellME(
                        "mint token: "
                        + str(_t)
                        + " to: "
                        + ad(str(someacc))
                        + " totalSup: "
                        + str(demo.totalSupply())
                        + "\n"
                    )
                    demo.singleMintArbi(_t, {"from": someacc})
                    sleep(0.05)
                    testo.singleMintArbi(_t, {"from": someacc})
                    # tokenByInd()
                except:

                    print("ERR ------- " + str(_t))
                    tellME("find :" + str(_t) + "\n")
                    l = [str(i) + " " for i in minted]
                    for i in l:
                        tellME(i)

                    tellME(str(_t))

                    tellME(("ERR ...............m2\n") * 5)
                    tokenByInd()
                    index_output_check()

                    raise (KeyboardInterrupt)

            else:
                try:
                    tellME("b\n")
                    sup = demo.totalSupply()
                    sleep(0.05)
                    try:
                        rndTok = minted.pop(random.randint(0, len(minted) - 1))
                        burned.append(rndTok)
                    except:

                        tellME("ERR b_tokenByIndex" + str(rndTok))
                        raise (KeyboardInterrupt)

                    try:
                        own = demo.ownerOf(rndTok)
                        sleep(0.05)
                    except:
                        tellME("ERR ownerOf" + str(rndTok))
                        raise (KeyboardInterrupt)

                    tellME(
                        "burn token: "
                        + str(rndTok)
                        + " to: "
                        + ad(str(own))
                        + " totalSup: "
                        + str(demo.totalSupply())
                        + "\n"
                    )

                    try:
                        demo.singleBurn(rndTok, {"from": own})  # .info()
                        sleep(0.05)
                    except:
                        tellME("ERR burnOfD" + str(rndTok))
                        raise (KeyboardInterrupt)

                    try:
                        testo.singleBurn(rndTok, {"from": own})
                        sleep(0.05)
                    except:
                        tellME("burnOfT" + str(rndTok))
                        raise (KeyboardInterrupt)
                    # try:
                    #     tokenByInd()
                    # except:
                    #     tellME("tokenByInd()" + str(rndTok))
                    #     raise (KeyboardInterrupt)
                    # sleep(0.05)
                except:
                    verbose = True
                    tellME(("ERR ...............b2\n") * 5)
                    tokenByInd()
                    index_output_check()
                    # print(tx)
                    raise (KeyboardInterrupt)

    def eval():
        total = 0
        ev = 0
        for i in range(num_acc):
            total += 1
            sleep(0.05)
            bal = demo.balanceOf(accounts[i])
            sleep(0.05)
            balt = testo.balanceOf(accounts[i])
            try:
                assert bal == balt
                ev += 1
            except:
                print("balances of ", i, "is", bal, balt)
            for j in range(bal):
                total += 1
                tok = demo.tokenOfOwnerByIndex(accounts[i], j)
                sleep(0.05)
                tokt = testo.tokenOfOwnerByIndex(accounts[i], j)
                sleep(0.05)
                try:
                    assert tok == tokt
                    ev += 1
                except:
                    print("skrew", i, j, tok, tokt)
                    # tellME("skrew")
                    Fi = open(
                        "./reports/report_Info.txt",
                        "a",
                    )
                    Fi.write(
                        ("index_output_check exept in i = " + str(i) + " j= " + str(j))
                    )
                    # Close the file
                    Fi.close()

        print("evaluation: ", ev, "/", total)
        Fi = open("./reports/report_Info.txt", "a")
        Fi.write(("\n evaluation: " + str(ev) + "/" + str(total) + "\n"))
        # Close the file
        Fi.close()
        if ev == total:
            return True
        else:
            return False

    # sd
    def index_output_check():
        Fi = open("./reports/report_Info.txt", "a")
        total = 0
        ev = 0
        nt = 0
        for i in range(num_acc):

            bal = demo.balanceOf(accounts[i])
            sleep(0.05)
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
                    tellME(
                        "index_output_check exept in i = "
                        + str(i)
                        + " j= "
                        + str(j)
                        + "\n"
                    )

        print("evaluation: ", ev, "/", total)
        # Fi = open("./reports/report_Info.txt", "a")
        Fi.write((" index-check \n evaluation: " + str(ev) + "/" + str(total) + "\n"))
        # Close the file
        Fi.close()

    for i in range(3):
        print(
            "acc " + str(i) + " balance : ",
            demo.balanceOf(accounts[i]),
            testo.balanceOf(accounts[i]),
        )
        print("start token: ", demo.getStart(accounts[i]))
    # for i in range(num_acc):
    #     print("balance", demo.balanceOf(accounts[i]))
    for i in range(150):
        tokID = demo.tokenOfOwnerByIndex(accounts[i // 50], i % 50)
        print(i, "  ", tokID)
        sleep(0.5)
    for i in range(demo.totalSupply()):
        print("----------")
        own = demo.ownerOf(i)
        print("ownerOF demo ", i, " ", demo.ownerOf(i))
        print("ownerOF Testo ", i, " ", testo.ownerOf(i))
        ind = demo.ownerIndexByToken(own, i)
        print("index ", ind)
        sleep(0.25)
    sleep(200)
    print("fisrt check")
    index_output_check()
    # -----------------
    for i in range(1 + run):
        # print(i, flush=True)
        trans()
        sys.stdout.write(str(i))
        sys.stdout.flush()

    print("eval")
    eval()
    print("index-check")
    sleep(2)
    # index_output()
    index_output_check()
    # index_check()
    sleep(3)

    return demo


# luv you dude <3


def main():
    for i in range(1):
        r = random.randint(0, 1)  # tokens
        g = random.randint(7, 8)  # acc
        b = random.randint(50, 100)  # runs
        Fi = open("./reports/report_Info.txt", "a")
        k = "***************************************************************\n" * 10
        Fi.write(
            k + "\ntest no: " + str(i) + " runs: " + str(b) + " accs:" + str(g) + "\n"
        )
        # Close the file
        Fi.close()

        # r = random.randint(0, 1)  # tokens
        # g = random.randint(2, 8)  # acc
        # b = random.randint(10, 50)  # runs
        print(" tokens: ", r + 1, " acc: ", g, " runs: ", b)
        deploy_and_create(r, g, b, True)
