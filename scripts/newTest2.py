from sre_constants import SUCCESS
from scripts.helpful_scripts import get_account
from brownie import accounts, config, network, FT
from time import sleep


def deploy_and_create(mint_req=True):
    account = get_account()
    demo = FT.deploy([accounts[0], accounts[1], accounts[2]], {"from": account})
    sleep(0.1)
    print("balance of preOwner", demo.balanceOf(account))
    sleep(0.1)
    print("owner of 10", demo.ownerOf(10))
    sleep(0.1)
    demo.transferFrom(account, accounts[1], 0, {"from": account})
    sleep(0.1)
    demo.transferFrom(account, accounts[1], 1, {"from": account})
    sleep(0.1)
    demo.transferFrom(account, accounts[2], 2, {"from": account})
    sleep(0.1)
    print("balance of preOwner", demo.balanceOf(account))
    sleep(0.1)
    print("owner of 1", demo.ownerOf(1))
    sleep(0.1)
    print("balance of acc1 ", demo.balanceOf(accounts[1]))
    print("balance of acc2 ", demo.balanceOf(accounts[2]))
    print("checking for get approve for preOwner")
    demo.approve(accounts[3], 3, {"from": account})
    x = 0
    try:
        assert demo.getApproved(3) == accounts[3]
        print("approve from preowner to new owner success")
    except:
        x += 1
        print("goh0")
    # ------
    demo.transferFrom(account, accounts[2], 3, {"from": accounts[3]})
    try:
        assert demo.ownerOf(3) == accounts[2]
        print("aprove transfer success1")
    except:
        x += 1
        print("goh1")

    try:
        assert demo.getApproved(3) != accounts[3]
        print("aprove transfer success1-0: ", demo.getApproved(3))
    except:
        x += 1
        print("goh1")

    demo.approve(accounts[4], 0, {"from": accounts[1]})
    try:
        assert demo.getApproved(0) == accounts[4]
        print("aprove regular owner success2")
    except:
        x += 1
        print("goh2")

    # ------
    demo.transferFrom(accounts[1], accounts[6], 0, {"from": accounts[4]})
    try:
        assert demo.ownerOf(0) == accounts[6]
        print("transfer regular aprove success3")
    except:
        x += 1
        print("goh3")

    try:
        assert demo.getApproved(0) != accounts[4]
        print("aprove transfer success2-0: ", demo.getApproved(4))
    except:
        x += 1
        print("goh2-0")

    demo.setApprovalForAll(accounts[5], True, {"from": account})
    try:
        assert demo.isApprovedForAll(account, accounts[5]) == True
        print("approve for all pre owner success4")
    except:
        x += 1
        print("goh4")

    # ------
    demo.transferFrom(account, accounts[7], 10, {"from": accounts[5]})
    try:
        assert demo.ownerOf(10) == accounts[7]
        print("transfer approve for all for  preOwner success5")
    except:
        x += 1
        print("goh5")

    demo.setApprovalForAll(accounts[8], True, {"from": accounts[2]})
    try:
        assert demo.isApprovedForAll(account, accounts[5]) == True
        print(" Aprroveforall for regular owner succes6")
    except:
        x += 1
        print("goh6")

    # ------
    demo.transferFrom(accounts[2], accounts[9], 2, {"from": accounts[8]})
    try:
        assert demo.ownerOf(2) == accounts[9]
        print("transfer approve for all for  regular owner success7")
    except:
        x += 1
        print("goh7")

    for i in range(10):
        print("balance of acc ", i, demo.balanceOf(accounts[i]))
        # print("owner")

    for i in range(11):
        print("owner", i, " is ", demo.ownerOf(i))

    print("sleep..")
    sleep(0.2)
    print("number of exceptions:", x)
    sleep(2)
    print(demo.ownerOf(123))
    return demo


def main():
    deploy_and_create(True)
