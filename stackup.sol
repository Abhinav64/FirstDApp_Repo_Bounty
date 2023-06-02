// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract StackUp {

  enum PlayerQuestStatus {
    NOT_JOINED,
    JOINED,
    SUBMITTED
  }

  enum QuestReviewStatus {
    PENDING,
    REJECTED,
    APPROVED
  }

  struct Quest {
    uint256 questId;
    uint256 numberOfPlayers;
    string title;
    uint8 reward;
    uint256 numberOfRewards;
  }

  address public admin;
  uint256 public nextQuestId;
  mapping(uint256 => Quest) public quests;
  mapping(address => mapping(uint256 => PlayerQuestStatus)) public playerQuestStatuses;
  mapping(uint256 => mapping(address => QuestReviewStatus)) public questReviews;

  constructor() {
    admin = msg.sender;
  }

  function createQuest(
    string calldata title_,
    uint8 reward_,
    uint256 numberOfRewards_
  ) external {
    require(msg.sender == admin, "Only the admin can create quests");
    quests[nextQuestId].questId = nextQuestId;
    quests[nextQuestId].title = title_;
    quests[nextQuestId].reward = reward_;
    quests[nextQuestId].numberOfRewards = numberOfRewards_;
    nextQuestId++;
  }

  function joinQuest(uint256 questId) external questExists(questId) {
    require(
      playerQuestStatuses[msg.sender][questId] == PlayerQuestStatus.NOT_JOINED,
      "Player has already joined/submitted this quest"
    );
    playerQuestStatuses[msg.sender][questId] = PlayerQuestStatus.JOINED;

    Quest storage thisQuest = quests[questId];
    thisQuest.numberOfPlayers++;
  }

  function submitQuest(uint256 questId) external questExists(questId) {
    require(
      playerQuestStatuses[msg.sender][questId] == PlayerQuestStatus.JOINED,
      "Player must first join the quest"
    );
    playerQuestStatuses[msg.sender][questId] = PlayerQuestStatus.SUBMITTED;
  }

  function reviewSubmission(uint256 questId, address player, QuestReviewStatus reviewStatus) external onlyAdmin questExists(questId) {
    questReviews[questId][player] = reviewStatus;
  }

  function editQuest(uint256 questId, string calldata newTitle, uint8 newReward, uint256 newNumberOfRewards) external onlyAdmin questExists(questId) {
    quests[questId].title = newTitle;
    quests[questId].reward = newReward;
    quests[questId].numberOfRewards = newNumberOfRewards;
  }

  function deleteQuest(uint256 questId) external onlyAdmin questExists(questId) {
    delete quests[questId];
  }

  modifier questExists(uint256 questId) {
    require(quests[questId].reward != 0, "Quest does not exist");
    _;
  }

  modifier onlyAdmin() {
    require(msg.sender == admin, "Only the admin can perform this operation");
    _;
  }
}
