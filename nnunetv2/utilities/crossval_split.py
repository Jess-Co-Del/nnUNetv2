from typing import List

import numpy as np
from sklearn.model_selection import KFold


def generate_crossval_split(train_identifiers: List[str], seed=12345, n_splits=5,
                            val_fraction: float = 0.2) -> List[dict[str, List[str]]]:
    """
    Train/val/test splits, ``n_splits`` folds.

    The outer KFold partitions the whole dataset into ``n_splits`` disjoint "test" chunks -- taken together across
    every fold, each identifier ends up in exactly one fold's "test" set, so every sample is held out as test data
    at least once across the full split scheme. Within each fold's remaining (non-test) identifiers, a further
    seeded random split carves "val" (``val_fraction`` of that remainder, for monitoring/model selection during
    training) out of "train" (everything else) -- this is the same train/val pair nnU-Net's own
    ``nnUNetTrainer.do_split()`` already reads directly. "test" is new and purely additive: nothing in nnU-Net's
    own training loop reads it, so this needs no changes anywhere else -- it's there for downstream tooling (e.g.
    evaluating a trained fold on its own held-out test cases) to read straight out of ``splits_final.json``.
    """
    splits = []
    identifiers = np.array(train_identifiers)
    outer_kfold = KFold(n_splits=n_splits, shuffle=True, random_state=seed)
    for i, (trainval_idx, test_idx) in enumerate(outer_kfold.split(identifiers)):
        trainval_keys = identifiers[trainval_idx]
        test_keys = identifiers[test_idx]

        rnd = np.random.RandomState(seed + i)
        shuffled = rnd.permutation(len(trainval_keys))
        n_val = max(1, int(round(len(trainval_keys) * val_fraction))) if len(trainval_keys) > 1 else 0
        val_idx, train_idx = shuffled[:n_val], shuffled[n_val:]

        splits.append({
            'train': list(trainval_keys[train_idx]),
            'val': list(trainval_keys[val_idx]),
            'test': list(test_keys),
        })
    return splits
